import { type CardContext } from 'https://cardstack.com/base/card-api';

import GlimmerComponent from '@glimmer/component';
import {
  Query,
  codeRefWithAbsoluteURL,
  getCard,
  ResolvedCodeRef,
} from '@cardstack/runtime-common';

import { action } from '@ember/object';
import { restartableTask } from 'ember-concurrency';
import { BoxelSelect } from '@cardstack/boxel-ui/components';
import { tracked } from '@glimmer/tracking';

export class DropdownMenu extends GlimmerComponent<{
  Args: {
    context?: CardContext;
    query?: Query;
    model?: any;
    currentRealm?: URL;
    onSelect?: (value: any) => void;
  };
  Element: HTMLElement;
}> {
  <template>
    {{#let
      (component @context.prerenderedCardSearchComponent)
      as |PrerenderedCardSearch|
    }}
      <PrerenderedCardSearch
        @query={{this.query}}
        @format='atom'
        @realms={{this.realms}}
      >

        <:loading>
          Loading...
        </:loading>
        <:response as |cards|>
          <BoxelSelect
            @options={{cards}}
            @onChange={{this.onSelect}}
            @selected={{this.selected}}
            as |item|
          >
            {{#let (component item.component) as |Component|}}
              <Component />
            {{/let}}
          </BoxelSelect>
        </:response>
      </PrerenderedCardSearch>
    {{/let}}
  </template>

  @tracked selected: any = null; //state for selection
  @action onSelect(selection: any) {
    this.selected = selection;
    this.args.onSelect?.(selection);
  }

  // selecting a links to card
  private selectCard = restartableTask(async (id: string) => {
    //chosenCard
    let url = new URL(id);
    let cardResource = await getCard(url);
    await cardResource.loaded;
    let card = cardResource.card;
    //#Pattern2: Linking card
    //im not sure if this is the right way to do this
    let currentCardList = this.args.model['cardsList'] ?? [];
    if (card) {
      let newCardList = [...currentCardList, card];
      this.args.model['cardsList'] = newCardList;
    }

    // this.args.model;
    // this.args.fields;
  });

  get query() {
    let assigneeCodeRef = {
      name: 'TeamMember',
      module: 'productivity/task',
    } as ResolvedCodeRef;
    let codeRef = codeRefWithAbsoluteURL(
      assigneeCodeRef,
      this.args.currentRealm,
    );
    return {
      filter: {
        every: [
          {
            ...{
              type: codeRef,
            },
          },
          ,
        ],
      },
    };
  }

  get realms() {
    return ['http://localhost:4201/experiments/'];
  }
}
