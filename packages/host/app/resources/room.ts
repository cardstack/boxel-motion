import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

import { restartableTask } from 'ember-concurrency';
import { Resource } from 'ember-resources';

import type MatrixService from '../services/matrix-service';
import type {
  CardMessageContent,
  RoomCreateEvent,
  RoomNameEvent,
} from 'https://cardstack.com/base/matrix-event';
import { CardDef } from 'https://cardstack.com/base/card-api';
import { getCard } from '@cardstack/runtime-common';
import { EventStatus } from 'matrix-js-sdk';
import { TrackedMap } from 'tracked-built-ins';
import type { MatrixEvent as DiscreteMatrixEvent } from 'https://cardstack.com/base/matrix-event';

interface Args {
  named: {
    roomId: string | undefined;
    events: DiscreteMatrixEvent[] | undefined;
  };
}

interface RoomMemberInterface {
  userId: string;
  roomId?: string;
  displayName?: string;
  membership?: 'invite' | 'join' | 'leave';
  membershipDateTime?: Date;
  membershipInitiator?: string;
}

const ErrorMessage: Record<string, string> = {
  ['M_TOO_LARGE']: 'Message is too large',
};

class RoomMemberField implements RoomMemberInterface {
  userId: string;
  roomId?: string;
  displayName?: string;
  membership?: 'invite' | 'join' | 'leave';
  membershipDateTime?: Date;
  membershipInitiator?: string;

  constructor(
    init: Partial<RoomMemberInterface> & { userId: string } = { userId: '' },
  ) {
    this.userId = init.userId;
    Object.assign(this, init);
  }

  get name(): string | undefined {
    return this.displayName ?? this.userId?.split(':')[0].substring(1);
  }
}

interface RoomMessageInterface {
  message?: string;
  eventId?: string;
  author?: RoomMemberField;
  created?: Date;
  updated?: Date;
  attachedCardIds?: string[];
  index?: number;
  transactionId?: string | null;
  isStreamingFinished?: boolean;
  formattedMessage?: string;
  errorMessage?: string;
  clientGeneratedId?: string | null;
  status?: EventStatus | null;
}

type AttachedCardResource = {
  card: CardDef | undefined;
  loaded?: Promise<void>;
  cardError?: { id: string; error: Error };
};

export class RoomMessageField implements RoomMessageInterface {
  message?: string;
  eventId?: string;
  author?: RoomMemberField;
  created?: Date;
  updated?: Date;
  attachedCardIds?: string[];
  index?: number;
  transactionId?: string | null;
  isStreamingFinished?: boolean;
  formattedMessage?: string;
  errorMessage?: string;
  clientGeneratedId?: string | null;
  status?: EventStatus | null;
  constructor(init: Partial<RoomMessageInterface>) {
    Object.assign(this, init);
  }
  get isRetryable() {
    return (
      this.errorMessage && this.errorMessage !== ErrorMessage['M_TOO_LARGE']
    );
  }
  get attachedResources(): AttachedCardResource[] | undefined {
    if (!this.attachedCardIds?.length) {
      return undefined;
    }
    let cards = this.attachedCardIds.map((id) => {
      let card = getCard(new URL(id));
      if (!card) {
        return {
          card: undefined,
          cardError: {
            id,
            error: new Error(`cannot find card for id "${id}"`),
          },
        };
      }
      return card;
    });
    return cards;
  }
}

export class RoomModel {
  @tracked events: DiscreteMatrixEvent[] = [];

  get roomId() {
    return this.events.length > 0 ? this.events[0].room_id : undefined;
  }

  get created() {
    let event = this.events.find((e) => e.type === 'm.room.create') as
      | RoomCreateEvent
      | undefined;
    if (event) {
      return new Date(event.origin_server_ts);
    }
    return new Date();
  }

  get name() {
    // Read from this.events instead of this.newEvents to avoid a race condition bug where
    // newEvents never returns the m.room.name while the event is present in events
    let events = this.events
      .filter((e) => e.type === 'm.room.name')
      .sort(
        (a, b) => a.origin_server_ts - b.origin_server_ts,
      ) as RoomNameEvent[];
    if (events.length > 0) {
      return events.pop()!.content.name;
    }
    return;
  }
}

// The resource is an mirror of the RoomModel
// RoomModel holds a lot of meta + events

// RoomResource is a cache for RoomModel messages
export class RoomResource extends Resource<Args> {
  _messageCache: TrackedMap<string, RoomMessageField> = new TrackedMap();
  _memberCache: TrackedMap<string, RoomMemberField> = new TrackedMap();
  @tracked room: RoomModel | undefined;
  @tracked loading: Promise<void> | undefined;
  @service private declare matrixService: MatrixService;

  modify(_positional: never[], named: Args['named']) {
    console.log(`running resource again with ${named.roomId}`);
    console.log(named.events);
    this.loading = this.load.perform(named.roomId);
  }

  private load = restartableTask(async (roomId: string | undefined) => {
    this.room = roomId ? await this.matrixService.getRoom(roomId) : undefined;
    if (this.room && this.room.roomId) {
      await this.loadRoomMembers(this.room.roomId);
      await this.loadRoomMessages(this.room.roomId);
    }
  });

  get messages() {
    if (this._messageCache) {
      return [...this._messageCache.values()].sort(
        (a, b) => a.created.getTime() - b.created.getTime(),
      );
    }
    return [];
  }

  get members() {
    return Array.from(this._memberCache.values()) ?? [];
  }

  get invitedMembers() {
    return this.members.filter((m) => m.membership === 'invite');
  }

  get joinedMembers() {
    return this.members.filter((m) => m.membership === 'join');
  }

  get events() {
    return this.room ? this.room.events : [];
  }

  async loadRoomMembers(roomId: string) {
    for (let event of this.events) {
      if (event.type !== 'm.room.member') {
        continue;
      }
      let userId = event.state_key;
      let roomMemberArgs = {
        userId,
        displayName: event.content.displayname,
        membership: event.content.membership,
        membershipDateTime: new Date(event.origin_server_ts) || Date.now(),
        membershipInitiator: event.sender,
      };
      this.upsertRoomMember({
        roomId,
        ...roomMemberArgs,
      });
    }
  }

  async loadRoomMessages(roomId: string) {
    let index = this._messageCache.size;
    let newMessages = new Map<string, RoomMessageField>();
    for (let event of this.events) {
      if (event.type !== 'm.room.message') {
        continue;
      }
      let event_id = event.event_id;
      let update = false;
      if (event.content['m.relates_to']?.rel_type === 'm.replace') {
        event_id = event.content['m.relates_to'].event_id;
        update = true;
      }
      if (this._messageCache.has(event_id) && !update) {
        continue;
      }
      let author = this.upsertRoomMember({
        roomId,
        userId: event.sender,
      });
      let cardArgs = new RoomMessageField({
        author,
        created: new Date(event.origin_server_ts),
        updated: new Date(), // Changes every time an update from AI bot streaming is received, used for detecting timeouts
        message: event.content.body,
        formattedMessage: event.content.formatted_body,
        // These are not guaranteed to exist in the event
        transactionId: event.unsigned?.transaction_id || null,
        attachedCard: null,
        command: null,
        status: event.status,
        eventId: event.event_id,
        index,
      });
      if (event.status === 'cancelled' || event.status === 'not_sent') {
        (cardArgs as any).errorMessage =
          event.error?.data.errcode &&
          Object.keys(ErrorMessage).includes(event.error?.data.errcode)
            ? ErrorMessage[event.error?.data.errcode]
            : 'Failed to send';
      }
      if ('errorMessage' in event.content) {
        (cardArgs as any).errorMessage = event.content.errorMessage;
      }
      let messageField = undefined;
      if (event.content.msgtype === 'org.boxel.message') {
        // Safely skip over cases that don't have attached cards or a data type
        // let cardDocs = event.content.data?.attachedCardsEventIds
        //   ? event.content.data.attachedCardsEventIds.map((eventId) =>
        //       this.serializedCardFromFragments(eventId),
        //     )
        //   : [];
        // let attachedCardIds: string[] = [];
        // cardDocs.map((c) => {
        //   if (c.data.id) {
        //     attachedCardIds.push(c.data.id);
        //   }
        // });
        // if (attachedCardIds.length < cardDocs.length) {
        //   throw new Error(`cannot handle cards in room without an ID`);
        // }
        // cardArgs.clientGeneratedId = event.content.clientGeneratedId ?? null;
        messageField = {
          ...cardArgs,
          // attachedCardIds,
        };
      } else {
        // Text from the AI bot
        if (event.content.msgtype === 'm.text') {
          cardArgs.isStreamingFinished = !!event.content.isStreamingFinished; // Indicates whether streaming (message updating while AI bot is sending more content into the message) has finished
        }
        messageField = { ...cardArgs };
      }

      if (messageField) {
        // if the message is a replacement for other messages,
        // use `created` from the oldest one.
        if (newMessages.has(event_id)) {
          messageField.created = newMessages.get(event_id)!.created;
        }
        newMessages.set(
          (event.content as CardMessageContent).clientGeneratedId ?? event_id,
          messageField as any,
        );
      }
      for (let [id, message] of newMessages) {
        // The `id` can either be an `eventId` or `clientGeneratedId`.
        // For messages sent by the user, we prefer to use `clientGeneratedId`
        // because `eventId` can change in certain scenarios,
        // such as when resending a failed message or updating its status from sending to sent.
        this._messageCache.set(id, message);
      }
    }
  }

  upsertRoomMember({
    roomId,
    userId,
    displayName,
    membership,
    membershipDateTime,
    membershipInitiator,
  }: RoomMemberInterface): RoomMemberField | undefined {
    let member: RoomMemberField | undefined;
    member = this._memberCache.get(userId);
    if (
      // Create new member if it doesn't exist or if provided data is more recent
      member?.membershipDateTime &&
      membershipDateTime &&
      member.membershipDateTime.getTime() > Number(membershipDateTime)
    ) {
      return member;
    }
    if (!member) {
      let member = new RoomMemberField({ userId, roomId });
      if (displayName) {
        member.displayName = displayName;
      }
      if (membership) {
        member.membership = membership;
      }
      if (membershipDateTime != null) {
        member.membershipDateTime = new Date(membershipDateTime);
      }
      if (membershipInitiator) {
        member.membershipInitiator = membershipInitiator;
      }

      this._memberCache.set(userId, member);
    }

    return member;
  }

  // private serializedCardFromFragments(
  //   eventId: string,
  // ): LooseSingleCardDocument {
  //   let cache = fragmentCache.get(this);
  //   if (!cache) {
  //     throw new Error(`No card fragment cache exists for this room`);
  //   }

  //   let fragments: CardFragmentContent[] = [];
  //   let currentFragment: string | undefined = eventId;
  //   do {
  //     let fragment = cache.get(currentFragment);
  //     if (!fragment) {
  //       throw new Error(
  //         `No card fragment found in cache for event id ${eventId}`,
  //       );
  //     }
  //     fragments.push(fragment);
  //     currentFragment = fragment.data.nextFragment;
  //   } while (currentFragment);

  //   fragments.sort((a, b) => (a.data.index = b.data.index));
  //   if (fragments.length !== fragments[0].data.totalParts) {
  //     throw new Error(
  //       `Expected to find ${fragments[0].data.totalParts} fragments for fragment of event id ${eventId} but found ${fragments.length} fragments`,
  //     );
  //   }

  //   let cardDoc = JSON.parse(
  //     fragments.map((f) => f.data.cardFragment).join(''),
  //   ) as LooseSingleCardDocument;
  //   cardHashes.set(generateCardHashKey(this.roomId, cardDoc), eventId);
  //   return cardDoc;
  // }
}

export function getRoom(
  parent: object,
  roomId: () => string | undefined,
  events: () => any | undefined, //we need this to react to new roomAddEvent
) {
  return RoomResource.from(parent, () => ({
    named: {
      roomId: roomId(),
      events: events ? events() : [],
    },
  }));
}
