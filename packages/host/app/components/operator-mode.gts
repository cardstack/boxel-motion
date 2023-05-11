import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { Card, Format } from 'https://cardstack.com/base/card-api';
import Preview from './preview';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import CardCatalogModal from '@cardstack/host/components/card-catalog-modal';
import type CardService from '../services/card-service';
import getValueFromWeakMap from '../helpers/get-value-from-weakmap';
import { eq, not } from '@cardstack/boxel-ui/helpers/truth-helpers';
import cn from '@cardstack/boxel-ui/helpers/cn';
import { IconButton, Modal } from '@cardstack/boxel-ui';
import SearchSheet, {
  SearchSheetMode,
} from '@cardstack/host/components/search-sheet';
import { restartableTask } from 'ember-concurrency';
import {
  Deferred,
  type Actions,
  type CardRef,
} from '@cardstack/runtime-common';
import type LoaderService from '../services/loader-service';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

import { TrackedArray, TrackedWeakMap } from 'tracked-built-ins';
import { cardTypeDisplayName } from '@cardstack/host/helpers/card-type-display-name';

interface Signature {
  Args: {
    firstCardInStack: Card;
    onClose: () => void;
  };
}

export default class OperatorMode extends Component<Signature> {
  stack: TrackedArray<Card>; // deferred can be a part of this
  formats: WeakMap<Card, Format> = new TrackedWeakMap<Card, Format>(); // this could also be part of the stack
  requests: WeakMap<Card, Deferred<Card>> = new TrackedWeakMap<
    Card,
    Deferred<Card>
  >();

  //A variable to store value of card field
  //before in edit mode.
  cardFieldValues: WeakMap<Card, Map<string, any>> = new WeakMap<
    Card,
    Map<string, any>
  >();
  @service declare loaderService: LoaderService;
  @service declare cardService: CardService;
  @tracked searchSheetMode: SearchSheetMode = SearchSheetMode.Closed;

  constructor(owner: unknown, args: any) {
    super(owner, args);
    this.stack = new TrackedArray([this.args.firstCardInStack]);
  }

  @action onFocusSearchInput() {
    if (this.searchSheetMode == SearchSheetMode.Closed) {
      this.searchSheetMode = SearchSheetMode.SearchPrompt;
    }
  }

  @action onCancelSearchSheet() {
    this.searchSheetMode = SearchSheetMode.Closed;
  }

  @action addToStack(card: Card) {
    this.stack.push(card);
  }

  @action async edit(card: Card) {
    await this.saveCardFieldValues(card);
    this.formats.set(card, 'edit');
  }

  @action getFormat(card: Card): Format | undefined {
    return this.formats.get(card);
  }

  @action async close(card: Card) {
    await this.rollbackCardFieldValues(card);
    let index = this.stack.indexOf(card);
    this.stack.splice(index);
    this.stack = this.stack;
    if (this.stack.length === 0) {
      this.args.onClose();
    }
  }

  @action async cancel(card: Card) {
    let cardRequest = this.requests.get(card);
    if (cardRequest) {
      this.requests.delete(card);
      this.close(card);
    }
    await this.rollbackCardFieldValues(card);
    this.formats.set(card, 'isolated');
  }

  @action async save(card: Card) {
    let index: number | undefined = undefined;
    if (!card.id) {
      index = this.stack.indexOf(card);
    }
    await this.saveCardFieldValues(card);
    let updatedCard = await this.write.perform(card);
    if (index && updatedCard) {
      this.stack.splice(index); // remove new card editor

      let cardRequest = this.requests.get(card);
      if (cardRequest) {
        cardRequest.fulfill(updatedCard);
        this.requests.delete(card);
      }
    }
  }

  private write = restartableTask(async (card: Card) => {
    let updatedCard = await this.cardService.saveModel(card);
    this.formats.set(updatedCard, 'isolated');
    return updatedCard;
  });

  private async saveCardFieldValues(card: Card) {
    let fields = await this.cardService.getFields(card);
    for (let fieldName of Object.keys(fields)) {
      if (fieldName === 'id') continue;

      let field = fields[fieldName];
      if (
        (field.fieldType === 'contains' ||
          field.fieldType === 'containsMany') &&
        !(await this.cardService.isPrimitive(field.card))
      ) {
        await this.saveCardFieldValues((card as any)[fieldName]);
      }

      let cardFieldValue = this.cardFieldValues.get(card);
      if (!cardFieldValue) {
        cardFieldValue = new Map<string, any>();
      }
      cardFieldValue.set(fieldName, (card as any)[fieldName]);
      this.cardFieldValues.set(card, cardFieldValue);
    }
  }

  private publicAPI: Actions = {
    createCard: async (
      ref: CardRef,
      relativeTo: URL | undefined
    ): Promise<Card | undefined> => {
      let doc = { data: { meta: { adoptsFrom: ref } } };
      let newCard = await this.cardService.createFromSerialized(
        doc.data,
        doc,
        relativeTo ?? this.cardService.defaultURL
      );
      this.addToStack(newCard);
      this.formats.set(newCard, 'edit');
      this.requests.set(newCard, new Deferred());

      return await this.requests.get(newCard)?.promise;
    },
    // more CRUD ops to come...
  };

  private async rollbackCardFieldValues(card: Card) {
    let fields = await this.cardService.getFields(card);
    for (let fieldName of Object.keys(fields)) {
      if (fieldName === 'id') continue;

      let field = fields[fieldName];
      if (
        (field.fieldType === 'contains' ||
          field.fieldType === 'containsMany') &&
        !(await this.cardService.isPrimitive(field.card))
      ) {
        await this.rollbackCardFieldValues((card as any)[fieldName]);
      }

      let cardFieldValue = this.cardFieldValues.get(card);
      if (cardFieldValue) {
        (card as any)[fieldName] = cardFieldValue.get(fieldName);
      }
    }
  }

  cardOrderFromTop(count: number, i: number) {
    // 0 is the topmost card, 1 is the one behind it, and so on...
    return count - (i + 1);
  }

  <template>
    <Modal
      class='operator-mode'
      @isOpen={{true}}
      @onClose={{@onClose}}
      @isOverlayDismissalDisabled={{true}}
      @boxelModalOverlayColor='var(--operator-mode-bg-color)'
    >
      <CardCatalogModal />
      <div class='stack'>
        {{#each this.stack as |card i|}}
          <div
            class='stack-card stack-card--{{this.cardOrderFromTop
                this.stack.length
                i
              }}'
            data-test-stack-card-index={{i}}
            data-test-stack-card={{card.id}}
          >
            <div
              class={{cn
                'operator-mode-card-stack__card__item'
                operator-mode-card-stack__card__item_edit=(eq
                  (getValueFromWeakMap this.formats card) 'edit'
                )
              }}
            >
              <Preview
                @card={{card}}
                @format={{this.getFormat card}}
                @actions={{this.publicAPI}}
              />
            </div>
            <div class='operator-mode-card-stack__card__header'>
              <div
                class='operator-mode-card-stack__card__header__type'
                data-type-display-name
              >{{cardTypeDisplayName card}}</div>
              {{#if (not (eq (getValueFromWeakMap this.formats card) 'edit'))}}
                <IconButton
                  @icon='icon-horizontal-three-dots'
                  @width='20px'
                  @height='20px'
                  class='icon-button'
                  aria-label='Edit'
                  {{on 'click' (fn this.edit card)}}
                  data-test-edit-button
                />
              {{/if}}
              <IconButton
                @icon='icon-x'
                @width='20px'
                @height='20px'
                class='icon-button'
                aria-label='Close'
                {{on 'click' (fn this.close card)}}
                data-test-close-button
              />
            </div>
            {{#if (eq (getValueFromWeakMap this.formats card) 'edit')}}
              <div class='operator-mode-card-stack__card__footer'>
                <button
                  class='operator-mode-card-stack__card__footer-button light-button'
                  {{on 'click' (fn this.cancel card)}}
                  aria-label='Cancel'
                  data-test-cancel-button
                >
                  Cancel
                </button>
                <button
                  class='operator-mode-card-stack__card__footer-button'
                  {{on 'click' (fn this.save card)}}
                  aria-label='Save'
                  data-test-save-button
                >
                  Save
                </button>
              </div>
            {{/if}}
          </div>
        {{/each}}
      </div>
      <SearchSheet
        @mode={{this.searchSheetMode}}
        @onCancel={{this.onCancelSearchSheet}}
        @onFocus={{this.onFocusSearchInput}}
      />
    </Modal>
  </template>
}

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry {
    OperatorMode: typeof OperatorMode;
  }
}
