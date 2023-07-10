import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import { Card, CardContext, Format } from 'https://cardstack.com/base/card-api';
import Preview from '@cardstack/host/components/preview';
import { fn, array } from '@ember/helper';

import { eq } from '@cardstack/boxel-ui/helpers/truth-helpers';
import optional from '@cardstack/boxel-ui/helpers/optional';
import cn from '@cardstack/boxel-ui/helpers/cn';
import { IconButton, Header, CardContainer, Button } from '@cardstack/boxel-ui';
import { type Actions, cardTypeDisplayName } from '@cardstack/runtime-common';

import { tracked } from '@glimmer/tracking';
import { TrackedArray } from 'tracked-built-ins';
import { schedule } from '@ember/runloop';

import BoxelDropdown from '@cardstack/boxel-ui/components/dropdown';
import BoxelMenu from '@cardstack/boxel-ui/components/menu';
import menuItem from '@cardstack/boxel-ui/helpers/menu-item';
import { StackItem } from '@cardstack/host/components/operator-mode/container';

import { htmlSafe, SafeString } from '@ember/template';
import OperatorModeOverlays from '@cardstack/host/components/operator-mode/overlays';
import ElementTracker from '../../resources/element-tracker';

interface Signature {
  Args: {
    item: StackItem;
    stackItems: StackItem[];
    index: number;
    publicAPI: Actions;
    cancel: (item: StackItem) => void;
    close: (item: StackItem) => void;
    delete: (item: StackItem) => void;
    dismissStackedCardsAbove: (stackIndex: number) => void;
    edit: (item: StackItem) => void;
    save: (item: StackItem) => void;
  };
}

export interface RenderedLinksToCard {
  element: HTMLElement;
  card: Card;
  context: CardContext;
  stackedAtIndex: number;
}

export default class OperatorModeStackItem extends Component<Signature> {
  @tracked selectedCards = new TrackedArray<Card>([]);

  cardTracker = new ElementTracker<{
    card: Card;
    format: Format;
    fieldType: string | undefined;
  }>();

  get renderedLinksToCards(): RenderedLinksToCard[] {
    return this.cardTracker.elements
      .filter((entry) => {
        return entry.meta.fieldType === 'linksTo';
      })
      // this mapping could probably be eliminated or simplified if we refactor OperatorModeOverlays to accept our type
      .map((entry) => ({
        element: entry.element,
        card: entry.meta.card,
        context: {}, // todo remove me
        stackedAtIndex: 0, // todo remove me
      }));
  }

  get styleForStackedCard(): SafeString {
    let itemsOnStackCount = this.args.stackItems.length;
    let invertedIndex = itemsOnStackCount - this.args.index - 1;
    let widthReductionPercent = 5; // Every new card on the stack is 5% wider than the previous one
    let offsetPx = 40; // Every new card on the stack is 40px lower than the previous one

    return htmlSafe(`
      width: ${100 - invertedIndex * widthReductionPercent}%;
      z-index: ${itemsOnStackCount - invertedIndex};
      padding-top: calc(${offsetPx}px * ${this.args.index});
    `);
  }

  get isBuried() {
    return this.args.index + 1 < this.args.stackItems.length;
  }

  get context() {
    return {
      renderedIn: this as Component<any>,
      cardComponentModifier: this.cardTracker.trackElement,
      actions: this.args.publicAPI,
    };
  }

  registerLinkedCardElement(
    linksToCardElement: HTMLElement,
    linksToCard: Card,
    context: CardContext
  ) {
    // Without scheduling this after render, this produces the "attempted to update value, but it had already been used previously in the same computation" type error
    schedule('afterRender', () => {
      this.renderedLinksToCards.push({
        element: linksToCardElement,
        card: linksToCard,
        stackedAtIndex: this.args.index,
        context,
      });
    });
  }

  unregisterLinkedCardElement(card: Card) {
    let index = this.renderedLinksToCards.findIndex(
      (renderedLinksToCard) => renderedLinksToCard.card === card
    );
    if (index !== -1) {
      this.renderedLinksToCards.splice(index, 1);
    }
  }

  @action toggleSelect(card: Card) {
    let index = this.selectedCards.findIndex((c) => c.id === card.id);

    if (index === -1) {
      this.selectedCards.push(card);
    } else {
      this.selectedCards.splice(index, 1);
    }
  }

  <template>
    <div
      class='item {{if this.isBuried "buried"}}'
      data-test-stack-card-index={{@index}}
      data-test-stack-card={{@item.card.id}}
      style={{this.styleForStackedCard}}
    >
      <CardContainer class={{cn 'card' edit=(eq @item.format 'edit')}}>
        <Header
          @title={{cardTypeDisplayName @item.card}}
          class='header'
          {{on
            'click'
            (optional (if this.isBuried (fn @dismissStackedCardsAbove @index)))
          }}
          data-test-stack-card-header
        >
          <:actions>
            <BoxelDropdown>
              <:trigger as |bindings|>
                <IconButton
                  @icon='icon-horizontal-three-dots'
                  @width='20px'
                  @height='20px'
                  class='icon-button'
                  aria-label='Options'
                  data-test-edit-button
                  {{bindings}}
                />
              </:trigger>
              <:content as |dd|>
                <BoxelMenu
                  @closeMenu={{dd.close}}
                  @items={{if
                    (eq @item.format 'edit')
                    (array
                      (menuItem
                        'Finish Editing'
                        (fn @save @item @index)
                        icon='icon-check-mark'
                      )
                      (menuItem
                        'Delete' (fn @delete @item @index) icon='icon-trash'
                      )
                    )
                    (array
                      (menuItem
                        'Edit' (fn @edit @item @index) icon='icon-pencil'
                      )
                    )
                  }}
                />
              </:content>
            </BoxelDropdown>
            <IconButton
              @icon='icon-x'
              @width='20px'
              @height='20px'
              class='icon-button'
              aria-label='Close'
              {{on 'click' (fn @close @item)}}
              data-test-close-button
            />
          </:actions>
        </Header>
        <div class='content'>
          <Preview
            @card={{@item.card}}
            @format={{@item.format}}
            @context={{this.context}}
          />
          <OperatorModeOverlays
            @renderedLinksToCards={{this.renderedLinksToCards}}
            @publicAPI={{@publicAPI}}
            @toggleSelect={{this.toggleSelect}}
            @selectedCards={{this.selectedCards}}
          />
        </div>
        {{#if (eq @item.format 'edit')}}
          <footer class='footer'>
            <Button
              @kind='secondary-light'
              @size='tall'
              class='footer-button'
              {{on 'click' (fn @cancel @item)}}
              aria-label='Cancel'
              data-test-cancel-button
            >
              Cancel
            </Button>
            <Button
              @kind='primary'
              @size='tall'
              class='footer-button'
              {{on 'click' (fn @save @item)}}
              aria-label='Save'
              data-test-save-button
            >
              Save
            </Button>
          </footer>
        {{/if}}
      </CardContainer>
    </div>
    <style>
      :global(:root) {
        --stack-card-footer-height: 5rem;
        --buried-operator-mode-header-height: 2.5rem;
      }

      .item {
        justify-self: center;
        position: absolute;
        width: 89%;
        height: inherit;
        z-index: 0;
        overflow: hidden;
        pointer-events: none;
      }

      .card {
        position: relative;
        height: 100%;
        display: grid;
        grid-template-rows: 7.5rem auto;
        box-shadow: 0 15px 30px 0 rgb(0 0 0 / 35%);
        pointer-events: auto;
      }

      .content {
        overflow: auto;
      }

      .content > .boxel-card-container.boundaries {
        box-shadow: none;
      }

      .content > .boxel-card-container > header {
        display: none;
      }

      .edit .content {
        margin-bottom: var(--stack-card-footer-height);
      }

      .footer {
        position: absolute;
        bottom: 0;
        right: 0;
        display: flex;
        justify-content: flex-end;
        padding: var(--boxel-sp);
        width: 100%;
        background: white;
        height: var(--stack-card-footer-height);
        border-top: 1px solid var(--boxel-300);
        border-bottom-left-radius: var(--boxel-border-radius);
        border-bottom-right-radius: var(--boxel-border-radius);
      }

      .footer-button + .footer-button {
        margin-left: var(--boxel-sp-xs);
      }

      .buried .card {
        background-color: var(--boxel-200);
        grid-template-rows: var(--buried-operator-mode-header-height) auto;
      }

      .buried .header .icon-button {
        display: none;
      }

      .buried .header {
        cursor: pointer;
        font: 500 var(--boxel-font-sm);
        padding: 0 var(--boxel-sp-xs);
      }
    </style>
  </template>
}

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry {
    OperatorModeStackItem: typeof OperatorModeStackItem;
  }
}
