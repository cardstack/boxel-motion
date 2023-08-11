import GlimmerComponent from '@glimmer/component';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import {
  primitive,
  type Box,
  type Format,
  type Field,
  type CardBase,
} from './card-api';
import { getBoxComponent, getPluralViewComponent } from './field-component';
import type { ComponentLike } from '@glint/template';
import { Button, IconButton } from '@cardstack/boxel-ui';

interface Signature {
  Args: {
    model: Box<CardBase>;
    arrayField: Box<CardBase[]>;
    format: Format;
    field: Field<typeof CardBase>;
    cardTypeFor(
      field: Field<typeof CardBase>,
      boxedElement: Box<CardBase>,
    ): typeof CardBase;
  };
}

class ContainsManyEditor extends GlimmerComponent<Signature> {
  <template>
    <div
      data-test-contains-many={{this.args.field.name}}
    >
      {{#if @arrayField.children.length}}
        <ul class='list'>
          {{#each @arrayField.children as |boxedElement i|}}
            <li class='links-to-editor FIXME' data-test-item={{i}}>
              {{#let
                (getBoxComponent
                  (this.args.cardTypeFor @field boxedElement)
                  @format
                  boxedElement
                  @field
                )
                as |Item|
              }}
                <Item />
              {{/let}}
              <IconButton
                @icon='icon-trash'
                @width='20px'
                @height='20px'
                class='remove-icon'
                {{on 'click' (fn this.remove i)}}
                data-test-remove={{i}}
                aria-label='Remove'
              />
            </li>
          {{/each}}
        </ul>
      {{/if}}
      <Button
        @size='small'
        {{on 'click' this.add}}
        type='button'
        data-test-add-new
      >+ Add New</Button>
    </div>
    <style>
      .list {
        list-style: none;
        padding: 0;
        margin: 0 0 var(--boxel-sp);
      }

      .list > li + li {
        margin-top: var(--boxel-sp);
      }

      .remove-icon {
        --icon-color: var(--boxel-red);
      }
      .remove-icon:hover {
        --icon-color: var(--boxel-error-200);
      }
    </style>
  </template>

  add = () => {
    // TODO probably each field card should have the ability to say what a new item should be
    let newValue =
      primitive in this.args.field.card ? null : new this.args.field.card();
    (this.args.model.value as any)[this.args.field.name].push(newValue);
  };

  remove = (index: number) => {
    (this.args.model.value as any)[this.args.field.name].splice(index, 1);
  };
}

export function getContainsManyComponent({
  model,
  arrayField,
  format,
  field,
  cardTypeFor,
}: {
  model: Box<CardBase>;
  arrayField: Box<CardBase[]>;
  format: Format;
  field: Field<typeof CardBase>;
  cardTypeFor(
    field: Field<typeof CardBase>,
    boxedElement: Box<CardBase>,
  ): typeof CardBase;
}): ComponentLike<{ Args: {}; Blocks: {} }> {
  if (format === 'edit') {
    return class ContainsManyEditorTemplate extends GlimmerComponent {
      <template>
        <ContainsManyEditor
          @model={{model}}
          @arrayField={{arrayField}}
          @field={{field}}
          @format={{format}}
          @cardTypeFor={{cardTypeFor}}
        />
      </template>
    };
  } else {
    return getPluralViewComponent(arrayField, field, format, cardTypeFor);
  }
}
