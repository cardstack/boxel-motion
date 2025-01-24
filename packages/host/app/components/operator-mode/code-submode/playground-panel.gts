import { action } from '@ember/object';
import type Owner from '@ember/owner';
import { service } from '@ember/service';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

import { restartableTask } from 'ember-concurrency';

import type { CardDef } from 'https://cardstack.com/base/card-api';

import { LoadingIndicator, BoxelSelect } from '@cardstack/boxel-ui/components';

import { getCards, type Query } from '@cardstack/runtime-common';
import type { CardType } from '@cardstack/host/resources/card-type';

import type RealmServerService from '@cardstack/host/services/realm-server';

interface Signature {
  Element: HTMLElement;
  Args: {
    cardType?: CardType;
  };
}

export default class PlaygroundPanel extends Component<Signature> {
  <template>
    <section class='playground-panel' data-test-playground-panel>
      {{#if this.isLoading}}
        <LoadingIndicator class='loading-icon' />
        Loading
        {{#if @cardType.isLoading}}
          card type...
        {{else if this.options.isLoading}}
          instances...
        {{/if}}
      {{else if this.instances.length}}
        <BoxelSelect
          class='instance-chooser'
          @options={{this.instances}}
          @selected='Instance: {{this.selectedOption}}'
          @onChange={{this.onSelect}}
          @placeholder='Please Select'
          as |item|
        >
          <div>{{item.title}}</div>
        </BoxelSelect>
      {{/if}}
    </section>
    <style scoped>
      .playground-panel {
        background-image: url('./playground-background.png');
        background-position: left top;
        background-repeat: repeat;
        background-size: 22.5px;
        height: 100%;
        width: 100%;
        background-color: var(--boxel-dark);
        color: var(--boxel-light);
        padding: var(--boxel-sp);
        overflow: auto;
      }
      .instance-chooser {
        color: var(--boxel-dark);
      }
      .loading-icon {
        display: inline-block;
        margin-right: var(--boxel-sp-xxxs);
        vertical-align: middle;
      }
    </style>
  </template>

  @service private declare realmServer: RealmServerService;
  @tracked selectedOption?: CardDef;
  @tracked options?: {
    instances: CardDef[];
    isLoading: boolean;
    loaded: Promise<void>;
  };

  constructor(owner: Owner, args: Signature['Args']) {
    super(owner, args);
    this.loadInstances.perform();
  }

  private loadInstances = restartableTask(async () => {
    if (this.args.cardType) {
      await this.args.cardType.ready;
      let codeRef = this.args.cardType?.type?.codeRef;
      if (codeRef) {
        let query: Query = {
          filter: { type: codeRef },
          sort: [{ by: 'createdAt', direction: 'desc' }],
        };
        this.options = getCards(query, this.realms);
      }
    }
  });

  private get isLoading() {
    return (
      this.loadInstances.isRunning ||
      this.args.cardType?.isLoading ||
      this.options?.isLoading
    );
  }

  private get realms() {
    return this.realmServer.availableRealmURLs;
  }

  private get instances() {
    return this.options?.instances;
  }

  @action private onSelect(opt: CardDef) {
    this.selectedOption = opt;
  }
}
