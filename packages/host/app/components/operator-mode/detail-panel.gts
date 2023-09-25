import { hash, array } from '@ember/helper';
import { action } from '@ember/object';
import { service } from '@ember/service';
import Component from '@glimmer/component';

import { type RealmInfo } from '@cardstack/runtime-common';

import { hasExecutableExtension } from '@cardstack/runtime-common';

import { type AdoptionChainResource } from '@cardstack/host/resources/adoption-chain';
import { type Ready } from '@cardstack/host/resources/file';

import { type CardDef } from 'https://cardstack.com/base/card-api';

import { lastModifiedDate } from '../../resources/last-modified-date';

import {
  FileDefinitionContainer,
  InstanceDefinitionContainer,
  ModuleDefinitionContainer,
  ClickableModuleDefinitionContainer,
} from './definition-container';

import type OperatorModeStateService from '../../services/operator-mode-state-service';

interface Args {
  Element: HTMLElement;
  Args: {
    realmInfo: RealmInfo | null;
    realmIconURL: string | null | undefined;
    readyFile: Ready;
    cardInstance: CardDef | undefined;
    adoptionChain?: AdoptionChainResource;
    delete: () => void;
  };
}

export default class DetailPanel extends Component<Args> {
  @service private declare operatorModeStateService: OperatorModeStateService;
  private lastModified = lastModifiedDate(this, () => this.args.readyFile);

  @action
  updateCodePath(url: URL | undefined) {
    if (url) {
      this.operatorModeStateService.updateCodePath(url);
    }
  }

  get adoptionChainTypes() {
    return this.args.adoptionChain?.types;
  }

  get isModule() {
    return hasExecutableExtension(this.args.readyFile.url);
  }

  private get fileExtension() {
    if (!this.args.cardInstance) {
      return '.' + this.args.readyFile.url.split('.').pop() || '';
    } else {
      return '';
    }
  }

  <template>
    <div class='container' ...attributes>
      {{#if @cardInstance}}
        {{! JSON case when visting, eg Author/1.json }}
        {{#each this.adoptionChainTypes as |t|}}
          <InstanceDefinitionContainer
            @name={{@cardInstance.title}}
            @fileExtension='.JSON'
            @realmInfo={{@realmInfo}}
            @realmIconURL={{@realmIconURL}}
            @infoText={{this.lastModified.value}}
            @actions={{array
              (hash label='Delete' handler=@delete icon='icon-trash')
            }}
          />
          <div>Adopts from</div>

          <ClickableModuleDefinitionContainer
            @name={{t.displayName}}
            @fileExtension={{this.fileExtension}}
            @realmInfo={{@realmInfo}}
            @realmIconURL={{@realmIconURL}}
            @onSelectDefinition={{this.updateCodePath}}
            @url={{t.module}}
          />
        {{/each}}
      {{else if this.isModule}}
        {{! Module case when visting, eg author.gts }}
        {{#each this.adoptionChainTypes as |t|}}
          <ModuleDefinitionContainer
            @name={{t.displayName}}
            @fileExtension={{this.fileExtension}}
            @realmInfo={{@realmInfo}}
            @realmIconURL={{@realmIconURL}}
            @infoText={{this.lastModified.value}}
            @isActive={{true}}
            @actions={{array
              (hash label='Delete' handler=@delete icon='icon-trash')
            }}
          />
          <div>Inherits from</div>
          <ClickableModuleDefinitionContainer
            @name={{t.super.displayName}}
            @fileExtension={{this.fileExtension}}
            @realmInfo={{@realmInfo}}
            @realmIconURL={{@realmIconURL}}
            @onSelectDefinition={{this.updateCodePath}}
            @url={{t.super.module}}
          />
        {{/each}}
      {{else}}
        <FileDefinitionContainer
          @fileExtension={{this.fileExtension}}
          @realmInfo={{@realmInfo}}
          @realmIconURL={{@realmIconURL}}
          @infoText={{this.lastModified.value}}
          @actions={{array
            (hash label='Delete' handler=@delete icon='icon-trash')
          }}
        />
      {{/if}}
    </div>
    <style>
      .container {
        display: flex;
        flex-direction: column;
        gap: var(--boxel-sp-xs);
      }
    </style>
  </template>
}
