import {
  OperatorModeState,
  Stack,
  StackItem,
} from '@cardstack/host/components/operator-mode';
import Service from '@ember/service';
import type CardService from '../services/card-service';
import { TrackedArray, TrackedObject } from 'tracked-built-ins';
import { service } from '@ember/service';

import { tracked } from '@glimmer/tracking';

// Below types form a raw POJO representation of operator mode state
type SerializedItem = { card: { id: string }; format: 'isolated' | 'edit' };
type SerializedStack = { items: SerializedItem[] };
export type SerializedState = { stacks: SerializedStack[] };

export default class OperatorModeStateService extends Service {
  @tracked state: OperatorModeState = new TrackedObject({
    stacks: new TrackedArray([]),
  });

  @service declare cardService: CardService;

  async restore(rawState: any) {
    this.state = await this.deserialize(rawState);
  }

  addItemToStack(item: StackItem, stackIndex = 0) {
    this.state.stacks[stackIndex].items.push(item);
  }

  removeItemFromStack(item: StackItem, stackIndex = 0) {
    let itemIndex = this.state.stacks[stackIndex].items.indexOf(item);
    this.state.stacks[stackIndex].items.splice(itemIndex);
  }

  replaceItemInStack(item: StackItem, newItem: StackItem, stackIndex = 0) {
    let itemIndex = this.state.stacks[stackIndex].items.indexOf(item);
    this.state.stacks[stackIndex].items.splice(itemIndex, 1, newItem);
  }

  clearStack(stackIndex = 0) {
    this.state.stacks[stackIndex].items.splice(0);
  }

  // Serialized POJO version of state, with only cards that have been saved.
  // The state can have cards that have not been saved yet, for example when
  // clicking on "Crate New" in linked card editor. Here we want to draw a boundary
  // between navigatable states in the query parameter
  rawStateWithSavedCardsOnly() {
    let state: SerializedState = { stacks: [] };

    for (let stack of this.state.stacks) {
      let _stack: SerializedStack = { items: [] };

      for (let item of stack.items) {
        let cardId = item.card.id;
        let card = { id: cardId };

        if (cardId) {
          if (item.format === 'isolated' || item.format === 'edit') {
            _stack.items.push({ card, format: item.format });
          } else {
            throw new Error(`Unknown format for card on stack ${item.format}`);
          }
        }
      }

      state.stacks.push(_stack);
    }

    return state;
  }

  // Stringified JSON version of state, with only cards that have been saved, used for URL query param
  serialize(): string {
    return JSON.stringify(this.rawStateWithSavedCardsOnly());
  }

  // Deserialize a stringified JSON version of OperatorModeState into a Glimmer tracked object
  // so that templates can react to changes in stacks and their items
  async deserialize(rawState: SerializedState): Promise<OperatorModeState> {
    let newState: OperatorModeState = new TrackedObject({
      stacks: [],
    });

    for (let stack of rawState.stacks) {
      let newStack: Stack = { items: new TrackedArray([]) };
      for (let item of stack.items) {
        let cardUrl = new URL(item.card.id);
        let card = await this.cardService.loadModel(cardUrl);
        newStack.items.push({ card, format: item.format });
      }
      newState.stacks.push(newStack);
    }

    return newState;
  }
}
