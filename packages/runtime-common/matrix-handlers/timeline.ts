import debounce from 'lodash/debounce';
import { type MatrixEvent } from 'matrix-js-sdk';
import { Context, setRoomMeta, Event } from './index';
import { eventDebounceMs } from '../index';

export function onTimeline(context: Context) {
  return (e: MatrixEvent) => {
    let { event } = e;
    if (
      event.type === 'm.room.encryption' &&
      // this is the only algorithm that matrix supports for room encryption
      event.content?.algorithm === 'm.megolm.v1.aes-sha2'
    ) {
      let { room_id: roomId } = event;
      if (!roomId) {
        throw new Error(
          `bug: roomId is undefined for message event ${JSON.stringify(
            event,
            null,
            2
          )}`
        );
      }
      setRoomMeta(context, roomId, { encrypted: true });
    } else {
      context.timelineQueue.push(e);
      debouncedTimelineDrain(context);
    }
  };
}

const debouncedTimelineDrain = debounce((context: Context) => {
  drainTimeline(context);
}, eventDebounceMs);

async function drainTimeline(context: Context) {
  await context.flushTimeline;

  let eventsDrained: () => void;
  context.flushTimeline = new Promise((res) => (eventsDrained = res));
  let events = [...context.timelineQueue];
  context.timelineQueue = [];
  for (let event of events) {
    await context.getClient().decryptEventIfNeeded(event);
    await processDecryptedEvent(context, {
      ...event.event,
      content: event.getContent() || undefined,
    });
  }
  eventsDrained!();
}

async function processDecryptedEvent(context: Context, event: Event) {
  let { event_id: eventId, room_id: roomId } = event;
  if (!eventId) {
    throw new Error(
      `bug: event ID is undefined for event ${JSON.stringify(event, null, 2)}`
    );
  }
  if (event.type === 'm.room.message' || event.type === 'm.room.encrypted') {
    if (!roomId) {
      throw new Error(
        `bug: roomId is undefined for message event ${JSON.stringify(
          event,
          null,
          2
        )}`
      );
    }
    let timeline = context.timelines.get(roomId);
    if (!timeline) {
      timeline = new context.mapClazz<string, Event>();
      context.timelines.set(roomId, timeline);
    }
    // we use a map for the timeline to de-dupe events
    let performCallback = !timeline.has(eventId);
    timeline.set(eventId, event);
    if (context.didReceiveMessages) {
      context.didReceiveMessages();
    }
    if (performCallback && context.handleMessage) {
      await context.handleMessage(context, event, roomId);
    }
  }
}
