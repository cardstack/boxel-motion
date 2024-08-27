import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

import { getContrastColor } from '../../helpers/contrast-color.ts';
import cssVar from '../../helpers/css-var.ts';
import { eq, not, or } from '../../helpers/truth-helpers.ts';
import cn from '../../helpers/cn.ts';
import { concat } from '@ember/helper';

export type BoxelTabVariant = 'default' | 'pills';

interface Signature {
  Args: {
    activeTabIndex?: number;
    headerBackgroundColor?: string;
    variant?: BoxelTabVariant;
    onSetActiveTab?: (index: number) => void;
    tabs?: Array<{
      displayName: string;
      tabId: string;
    }>;
    title: string;
  };
  Blocks: {
    default: [];
    headerIcon: [];
  };
  Element: HTMLDivElement;
}

export default class TabbedHeader extends Component<Signature> {
  defaultVariant: BoxelTabVariant = 'default';

  <template>
    <header
      class='app-header'
      style={{cssVar
        header-background-color=@headerBackgroundColor
        header-text-color=(getContrastColor @headerBackgroundColor)
      }}
    >
      <div class='app-title-group'>
        {{#if (has-block 'headerIcon')}}
          {{yield to='headerIcon'}}
        {{/if}}
        <h1 class='app-title'>{{@title}}</h1>
      </div>
      <nav class='app-nav'>
        <ul
          class={{cn
            (if
              (or (eq @variant 'default') (eq @variant '') (not @variant))
              'app-tab-list'
            )
            (if (eq @variant 'pills') 'app-tab-list-pills')
          }}
        >
          {{#each @tabs as |tab index|}}
            <li>
              <a
                href='#{{tab.tabId}}'
                {{on 'click' (fn this.setActiveTab index)}}
                class={{cn
                  (concat 'variant-' (if @variant @variant this.defaultVariant))
                  (if (eq this.activeTabIndex index) 'active')
                }}
                data-tab-label={{tab.displayName}}
                {{! do not remove data-tab-label attribute }}
              >
                {{tab.displayName}}
              </a>
            </li>
          {{/each}}
        </ul>
      </nav>
    </header>
    <style>
      .app-header {
        padding: 0 var(--boxel-sp-lg);
        background-color: var(--header-background-color, var(--boxel-light));
        color: var(--header-text-color, var(--boxel-dark));
      }
      .app-title-group {
        padding: var(--boxel-sp-xs) 0;
        display: flex;
        align-items: center;
        gap: var(--boxel-sp-xs);
      }
      .app-title {
        margin: 0;
        font: 900 var(--boxel-font);
        letter-spacing: var(--boxel-lsp-xl);
        text-transform: uppercase;
      }
      .app-nav {
        font: 500 var(--boxel-font-sm);
        letter-spacing: var(--boxel-lsp-sm);
      }
      .app-tab-list {
        list-style-type: none;
        padding: 0;
        margin: 0;
        display: flex;
        gap: var(--boxel-sp);
        flex-flow: row wrap;
      }
      .app-tab-list a {
        height: 100%;
        padding: var(--boxel-sp-xs) var(--boxel-sp-xxs);
        border-bottom: 4px solid transparent;
        transition:
          border-bottom-color 0.3s ease-in-out,
          font-weight 0.3s ease-in-out;
      }
      .app-tab-list a.active {
        color: var(--header-text-color, var(--boxel-dark));
        border-bottom-color: var(--header-text-color, var(--boxel-dark));
        font-weight: 700;
      }
      .app-tab-list a:hover:not(:disabled) {
        color: var(--header-text-color, var(--boxel-dark));
        font-weight: 700;
      }
      /* this prevents layout shift when text turns bold on hover/active */
      .app-tab-list a::after {
        display: block;
        content: attr(data-tab-label);
        height: 0;
        visibility: hidden;
        user-select: none;
        pointer-events: none;
        font-weight: 700;
      }

      .app-tab-list-pills {
        list-style-type: none;
        padding: var(--boxel-sp-4xs);
        margin: 0;
        display: flex;
        flex-flow: row wrap;
        gap: var(--boxel-sp-5xs);
      }
      a.variant-pills {
        height: 100%;
        padding: var(--boxel-sp-xs) var(--boxel-sp-lg);
        border-bottom: 0px;
        background: var(--boxel-100);
        border-radius: var(--boxel-border-radius-xs);
        transition:
          border-bottom-color 0.3s ease-in-out,
          font-weight 0.3s ease-in-out;
      }
      a.variant-pills.active {
        color: var(--boxel-light);
        background: var(--boxel-teal);
        font-weight: 700;
      }
      a.variant-pills:hover:not(:disabled) {
        color: var(--header-text-color, var(--boxel-dark));
        font-weight: 700;
      }
      /* this prevents layout shift when text turns bold on hover/active */
      a.variant-pills::after {
        content: '';
      }
    </style>
  </template>

  @tracked activeTabIndex =
    this.args.activeTabIndex && this.args.activeTabIndex !== -1
      ? this.args.activeTabIndex
      : 0;

  @action setActiveTab(index: number) {
    this.activeTabIndex = index;
    this.args.onSetActiveTab?.(index);
  }
}
