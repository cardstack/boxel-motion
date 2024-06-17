import Service, { service } from '@ember/service';

import { task } from 'ember-concurrency';

import { PatchData } from '@cardstack/runtime-common';

import type MatrixService from '@cardstack/host/services/matrix-service';
import type OperatorModeStateService from '@cardstack/host/services/operator-mode-state-service';
import { CommandField } from 'https://cardstack.com/base/room';

export default class CommandService extends Service {
  @service declare operatorModeStateService: OperatorModeStateService;
  @service private declare matrixService: MatrixService;

  run = task(async (command: CommandField, roomId: string) => {
    let { payload, eventId } = command;
    try {
      this.matrixService.failedCommandState.delete(eventId);
      if (command.name === 'patchCard') {
        if (!hasPatchData(payload)) {
          throw new Error(
            "Patch command can't run because it doesn't have all the fields in payload",
          );
        }
        await this.operatorModeStateService.patchCard.perform(payload.card_id, {
          attributes: payload.attributes,
          relationships: payload.relationships,
        });
      }
      await this.matrixService.sendReactionEvent(roomId, eventId, 'applied');
    } catch (e) {
      let error =
        typeof e === 'string'
          ? new Error(e)
          : e instanceof Error
          ? e
          : new Error('Command failed.');
      this.matrixService.failedCommandState.set(eventId, error);
    }
  });
}

type PatchPayload = { card_id: string } & PatchData;

function hasPatchData(payload: any): payload is PatchPayload {
  return (
    (typeof payload === 'object' &&
      payload !== null &&
      'card_id' in payload &&
      'attributes' in payload) ||
    (typeof payload === 'object' &&
      payload !== null &&
      'card_id' in payload &&
      'relationships' in payload)
  );
}
