import GlimmerComponent from '@glimmer/component';
import { on } from '@ember/modifier';
import {
  restartableTask,
  type EncapsulatedTaskDescriptor as Descriptor,
} from 'ember-concurrency';
import { getBoxComponent } from './field-component';
import { type Card, type Box, type Field } from './card-api';
import {
  chooseCard,
  baseCardRef,
  identifyCard,
} from '@cardstack/runtime-common';
import type { ComponentLike } from '@glint/template';
import { CardContainer, Button, IconButton } from '@cardstack/boxel-ui';

interface Signature {
  Args: {
    model: Box<Card | null>;
    field: Field<typeof Card>;
    actions?: { createCard: (card: typeof Card) => void };
  };
}

class LinksToEditor extends GlimmerComponent<Signature> {
  <template>
    <div class='links-to-editor{{if this.isEmpty "--empty"}}'>
      {{#if this.isEmpty}}
        <Button @size='small' {{on 'click' this.choose}} data-test-choose-card>
          Choose
        </Button>
        {{#if @actions.createCard}}
          <Button @size='small' {{on 'click' this.create}} data-test-create-new>
            Create New
          </Button>
        {{/if}}
      {{else}}
        <CardContainer class='links-to-editor__item'>
          <this.linkedCard />
        </CardContainer>
        <IconButton
          @icon='icon-minus-circle'
          @width='20px'
          @height='20px'
          class='icon-button'
          aria-label='Remove'
          {{on 'click' this.remove}}
          disabled={{this.isEmpty}}
          data-test-remove-card
        />
      {{/if}}
    </div>
  </template>

  choose = () => {
    (this.chooseCard as unknown as Descriptor<any, any[]>).perform();
  };

  create = () => {
    (this.createCard as unknown as Descriptor<any, any[]>).perform();
  };

  remove = () => {
    this.args.model.value = null;
  };

  get isEmpty() {
    return this.args.model.value == null;
  }

  get linkedCard() {
    if (this.args.model.value == null) {
      throw new Error(
        `can't make field component with box value of null for field ${this.args.field.name}`
      );
    }
    let card = Reflect.getPrototypeOf(this.args.model.value)!
      .constructor as typeof Card;
    return getBoxComponent(card, 'embedded', this.args.model as Box<Card>);
  }

  private chooseCard = restartableTask(async () => {
    let type = identifyCard(this.args.field.card) ?? baseCardRef;
    let chosenCard: Card | undefined = await chooseCard({ filter: { type } });
    if (chosenCard) {
      this.args.model.value = chosenCard;
    }
  });

  private createCard = restartableTask(async () => {
    console.log(this.args.actions);
    this.args.actions?.createCard(this.args.field.card);
    // let type = identifyCard(this.args.field.card) ?? baseCardRef;
    // let newCard = await createNewCard(type);
    // if (newCard) {
    //   this.args.model.value = newCard;
    // }
  });
}

export function getLinksToEditor(
  model: Box<Card | null>,
  field: Field<typeof Card>
): ComponentLike<{ Args: {}; Blocks: {} }> {
  return class LinksToEditTemplate extends GlimmerComponent {
    <template>
      <LinksToEditor @model={{model}} @field={{field}} />
    </template>
  };
}
