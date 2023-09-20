import Component from '@glimmer/component';
import { internalKeyFor } from '@cardstack/runtime-common';
import { isCodeRef, type CodeRef } from '@cardstack/runtime-common/code-ref';
import { type Type } from '@cardstack/host/resources/card-type';
import { action } from '@ember/object';
import { service } from '@ember/service';

import type LoaderService from '@cardstack/host/services/loader-service';
import type CardService from '@cardstack/host/services/card-service';
import type { ModuleSyntax } from '@cardstack/runtime-common/module-syntax';
import type { Ready } from '@cardstack/host/resources/file';
import type { BaseDef } from 'https://cardstack.com/base/card-api';
import { capitalize } from '@ember/string';

interface Signature {
  Args: {
    card: typeof BaseDef;
    file: Ready;
    cardType: Type;
    moduleSyntax: ModuleSyntax;
  };
}

export default class CardSchemaEditor extends Component<Signature> {
  <template>
    <style>
      .schema-editor-container {
        margin-top: var(--boxel-sp);
      }

      .schema {
        display: grid;
        gap: var(--boxel-sp);
        padding: var(--boxel-sp);
      }

      .pill {
        border: 1px solid gray;
        display: inline-block;
        padding: var(--boxel-sp-xxxs) var(--boxel-sp-xs);
        border-radius: 8px;
        background-color: white;
        font-weight: 600;
      }

      .realm-icon {
        margin-right: var(--boxel-sp-xxxs);
      }

      .card-field {
        background-color: white;
      }

      .card-field {
        margin-bottom: var(--boxel-sp-xs);
        padding: var(--boxel-sp);
        border-radius: var(--boxel-border-radius);
        display: flex;
      }

      .card-fields {
        margin-top: var(--boxel-sp);
      }

      .left {
        display: flex;
        margin-top: auto;
        margin-bottom: auto;
        flex-direction: column;
      }

      .right {
        margin-left: auto;
        margin-top: auto;
        margin-bottom: auto;
      }

      .field-name {
        font-size: var(--boxel-font-size);
      }

      .field-type {
        color: #949494;
      }
    </style>

    <div
      class='schema-editor-container'
      data-test-card-schema={{@cardType.displayName}}
    >
      <div class='pill'>
        <span class='realm-icon'>
          🟦
        </span>
        {{@cardType.displayName}}
      </div>

      <div class='card-fields'>
        {{#each @cardType.fields as |field|}}
          {{#if (this.isOwnField field.name)}}
            <div class='card-field' data-test-field-name={{field.name}}>
              <div class='left'>
                <div class='field-name'>
                  {{field.name}}
                </div>
                <div class='field-type'>
                  {{field.type}}
                </div>
              </div>
              <div class='right'>

                <div class='pill'>
                  <span class='realm-icon'>
                    🟪
                  </span>
                  {{#let
                    (this.fieldCardDisplayName field.card)
                    as |cardDisplayName|
                  }}
                    <span
                      data-test-card-display-name={{cardDisplayName}}
                    >{{cardDisplayName}}</span>
                  {{/let}}
                </div>
              </div>
            </div>
          {{/if}}
        {{/each}}
      </div>
    </div>
  </template>

  @service declare loaderService: LoaderService;
  @service declare cardService: CardService;

  @action
  isOwnField(fieldName: string): boolean {
    return Object.keys(
      Object.getOwnPropertyDescriptors(this.args.card.prototype),
    ).includes(fieldName);
  }

  fieldCardDisplayName(card: Type | CodeRef): string {
    if (isCodeRef(card)) {
      return internalKeyFor(card, undefined);
    }
    return card.displayName;
  }
}
