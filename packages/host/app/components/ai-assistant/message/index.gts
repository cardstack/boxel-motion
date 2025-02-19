import type { TemplateOnlyComponent } from '@ember/component/template-only';
import { registerDestructor } from '@ember/destroyable';
import { on } from '@ember/modifier';
import { service } from '@ember/service';
import type { SafeString } from '@ember/template';
import { htmlSafe } from '@ember/template';
import Component from '@glimmer/component';

import { format as formatDate, formatISO } from 'date-fns';
import Modifier from 'ember-modifier';
import throttle from 'lodash/throttle';

import { Button } from '@cardstack/boxel-ui/components';
import { and, cn } from '@cardstack/boxel-ui/helpers';
import { FailureBordered } from '@cardstack/boxel-ui/icons';

import { isCardInstance } from '@cardstack/runtime-common';

import CardPill from '@cardstack/host/components/card-pill';
import FilePill from '@cardstack/host/components/file-pill';
import CodeBlock from '@cardstack/host/modifiers/code-block';
import { MonacoEditorOptions } from '@cardstack/host/modifiers/monaco';

import type CardService from '@cardstack/host/services/card-service';
import { type MonacoSDK } from '@cardstack/host/services/monaco-service';

import { type CardDef } from 'https://cardstack.com/base/card-api';
import { type FileDef } from 'https://cardstack.com/base/file-api';

import type { ComponentLike } from '@glint/template';

function findLastTextNodeWithContent(parentNode: Node): Text | null {
  // iterate childNodes in reverse to find the last text node with non-whitespace text
  for (let i = parentNode.childNodes.length - 1; i >= 0; i--) {
    let child = parentNode.childNodes[i];
    if (child.textContent && child.textContent.trim() !== '') {
      if (child instanceof Text) {
        return child;
      }
      return findLastTextNodeWithContent(child);
    }
  }
  return null;
}

function wrapLastTextNodeInStreamingTextSpan(html: SafeString): SafeString {
  let parser = new DOMParser();
  let doc = parser.parseFromString(html.toString(), 'text/html');
  let lastTextNode = findLastTextNodeWithContent(doc.body);
  if (lastTextNode) {
    let span = doc.createElement('span');
    span.textContent = lastTextNode.textContent;
    span.classList.add('streaming-text');
    lastTextNode.replaceWith(span);
  }
  return htmlSafe(doc.body.innerHTML);
}

interface Signature {
  Element: HTMLDivElement;
  Args: {
    formattedMessage: SafeString;
    datetime: Date;
    isFromAssistant: boolean;
    isStreaming: boolean;
    profileAvatar?: ComponentLike;
    resources?: {
      cards: CardDef[] | undefined;
      files: FileDef[] | undefined;
      errors: { id: string; error: Error }[] | undefined;
    };
    index: number;
    monacoSDK: MonacoSDK;
    registerScroller: (args: {
      index: number;
      element: HTMLElement;
      scrollTo: Element['scrollIntoView'];
    }) => void;
    errorMessage?: string;
    isPending?: boolean;
    retryAction?: () => void;
  };
  Blocks: { default: [] };
}

interface MessageScrollerSignature {
  Args: {
    Named: {
      index: number;
      registerScroller: (args: {
        index: number;
        element: HTMLElement;
        scrollTo: Element['scrollIntoView'];
      }) => void;
    };
  };
}

class MessageScroller extends Modifier<MessageScrollerSignature> {
  private hasRegistered = false;
  private observer?: MutationObserver;
  modify(
    element: HTMLElement,
    _positional: [],
    { index, registerScroller }: MessageScrollerSignature['Args']['Named'],
  ) {
    if (!this.hasRegistered) {
      this.hasRegistered = true;
      registerScroller({
        index,
        element,
        scrollTo: element.scrollIntoView.bind(element),
      });
    }

    this.observer?.disconnect();

    this.observer = new MutationObserver(() => {
      registerScroller({
        index,
        element,
        scrollTo: element.scrollIntoView.bind(element),
      });
    });
    this.observer.observe(element, { childList: true, subtree: true });

    registerDestructor(this, () => {
      this.observer?.disconnect();
    });
  }
}

interface ScrollPositionSignature {
  Args: {
    Named: {
      setScrollPosition: (args: { isBottom: boolean }) => void;
      registerConversationScroller: (
        isScrollable: () => boolean,
        scrollToBottom: () => void,
      ) => void;
    };
  };
}

// an amount of pixels from the bottom of the element that we would consider to
// be scrolled "all the way down"
const BOTTOM_THRESHOLD = 50;
class ScrollPosition extends Modifier<ScrollPositionSignature> {
  private hasRegistered = false;
  modify(
    element: HTMLElement,
    _positional: [],
    {
      setScrollPosition,
      registerConversationScroller,
    }: ScrollPositionSignature['Args']['Named'],
  ) {
    if (!this.hasRegistered) {
      this.hasRegistered = true;
      registerConversationScroller(
        () => element.scrollHeight > element.clientHeight,
        () => {
          element.scrollTop = element.scrollHeight - element.clientHeight;
        },
      );
    }

    let detectPosition = throttle(() => {
      let isBottom =
        Math.abs(
          element.scrollHeight - element.clientHeight - element.scrollTop,
        ) <= BOTTOM_THRESHOLD;
      setScrollPosition({ isBottom });
    }, 500);
    element.addEventListener('scroll', detectPosition);
    registerDestructor(this, () =>
      element.removeEventListener('scroll', detectPosition),
    );
  }
}

export default class AiAssistantMessage extends Component<Signature> {
  @service private declare cardService: CardService;

  <template>
    <div
      class={{cn
        'ai-assistant-message'
        is-from-assistant=@isFromAssistant
        is-pending=@isPending
        is-error=@errorMessage
      }}
      {{MessageScroller index=@index registerScroller=@registerScroller}}
      {{CodeBlock
        codeBlockSelector='pre[data-codeblock]'
        languageAttr='data-codeblock'
        monacoSDK=@monacoSDK
        editorDisplayOptions=this.editorDisplayOptions
        index=@index
      }}
      data-test-ai-assistant-message
      ...attributes
    >
      <div class='meta'>
        {{#if @isFromAssistant}}
          <div
            class='ai-avatar {{if this.isAvatarAnimated "ai-avatar-animated"}}'
            data-test-ai-avatar
          ></div>
        {{else if @profileAvatar}}
          <@profileAvatar />
        {{/if}}
        <time datetime={{formatISO @datetime}} class='time'>
          {{formatDate @datetime 'iiii MMM d, yyyy, h:mm aa'}}
        </time>
      </div>
      <div class='content-container'>
        {{#if @errorMessage}}
          <div class='error-container'>
            <FailureBordered class='error-icon' />
            <div class='error-message' data-test-card-error>
              {{@errorMessage}}
            </div>

            {{#if @retryAction}}
              <Button
                {{on 'click' @retryAction}}
                class='retry-button'
                @size='small'
                @kind='secondary-dark'
                data-test-ai-bot-retry-button
              >
                Retry
              </Button>
            {{/if}}
          </div>
        {{/if}}

        <div class='content' data-test-ai-message-content>
          {{if
            (and @isFromAssistant @isStreaming)
            (wrapLastTextNodeInStreamingTextSpan @formattedMessage)
            @formattedMessage
          }}

          {{yield}}

          {{#if this.items.length}}
            <div class='items' data-test-message-items>
              {{#each this.items as |item|}}
                {{#if (isCardInstance item)}}
                  <CardPill @card={{item}} />
                {{else}}
                  <FilePill @file={{item}} />
                {{/if}}
              {{/each}}
            </div>
          {{/if}}

          {{#if @resources.errors.length}}
            <div class='error-container'>
              {{#each @resources.errors as |resourceError|}}
                <FailureBordered class='error-icon' />
                <div class='error-message' data-test-card-error>
                  <div>Cannot render {{resourceError.id}}</div>
                </div>
              {{/each}}
            </div>
          {{/if}}
        </div>
      </div>
    </div>

    <style scoped>
      .ai-assistant-message {
        --ai-bot-message-background-color: #3b394b;
        --ai-assistant-message-avatar-size: 1.25rem; /* 20px. */
        --ai-assistant-message-meta-height: 1.25rem; /* 20px */
        --ai-assistant-message-gap: var(--boxel-sp-xs);
        --profile-avatar-icon-size: var(--ai-assistant-message-avatar-size);
        --profile-avatar-icon-border: 1px solid var(--boxel-400);
      }
      .meta {
        display: grid;
        grid-template-columns: var(--ai-assistant-message-avatar-size) 1fr;
        grid-template-rows: var(--ai-assistant-message-meta-height);
        align-items: center;
        gap: var(--ai-assistant-message-gap);
      }
      .ai-avatar {
        width: var(--ai-assistant-message-avatar-size);
        height: var(--ai-assistant-message-avatar-size);

        background-image: image-set(
          url('../ai-assist-icon.webp') 1x,
          url('../ai-assist-icon@2x.webp') 2x,
          url('../ai-assist-icon@3x.webp')
        );
        background-repeat: no-repeat;
        background-size: var(--ai-assistant-message-avatar-size);
      }

      .ai-avatar-animated {
        background-image: url('../ai-assist-icon-animated.webp');
      }

      .avatar-img {
        width: var(--ai-assistant-message-avatar-size);
        height: var(--ai-assistant-message-avatar-size);
        border-radius: 100px;
      }

      .time {
        display: block;
        font: 500 var(--boxel-font-xs);
        letter-spacing: var(--boxel-lsp-sm);
        color: var(--boxel-450);
        white-space: nowrap;
      }

      /* spacing for sequential thread messages */
      .ai-assistant-message + .ai-assistant-message {
        margin-top: var(--boxel-sp-lg);
      }

      .ai-assistant-message + .hide-meta {
        margin-top: var(--boxel-sp);
      }

      .content-container {
        margin-top: var(--boxel-sp-xs);
        border-radius: var(--boxel-border-radius-xxs)
          var(--boxel-border-radius-xl) var(--boxel-border-radius-xl)
          var(--boxel-border-radius-xl);
        overflow: hidden;
      }

      .content {
        background-color: var(--boxel-light);
        color: var(--boxel-dark);
        font-size: var(--boxel-font-sm);
        font-weight: 500;
        line-height: 1.25rem;
        letter-spacing: var(--boxel-lsp-xs);
        padding: var(--ai-assistant-message-padding, var(--boxel-sp));
      }
      .is-from-assistant .content {
        background-color: var(--ai-bot-message-background-color);
        color: var(--boxel-light);
        /* the below font-smoothing options are only recommended for light-colored
          text on dark background (otherwise not good for accessibility) */
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
      }

      .is-from-assistant .content :deep(pre) {
        white-space: pre-wrap;
      }

      .is-from-assistant .content :deep(pre code) {
        overflow-wrap: break-word;
      }

      .is-pending .content,
      .is-pending .content .items > :deep(.card-pill),
      .is-pending .content .items > :deep(.card-pill .boxel-card-container) {
        background: var(--boxel-200);
        color: var(--boxel-500);
      }

      .is-error .content,
      .is-error .content .items > :deep(.card-pill),
      .is-error .content .items > :deep(.card-pill .boxel-card-container) {
        background: var(--boxel-200);
        color: var(--boxel-500);
        max-height: 300px;
        overflow: auto;
      }

      .content :deep(span.streaming-text:after) {
        content: '';
        width: 8px;
        height: 8px;
        background: currentColor;
        border-radius: 50%;
        display: inline-block;
        font-family: system-ui, sans-serif;
        line-height: normal;
        vertical-align: baseline;
        margin-left: 5px;
      }

      .content > :deep(.command-message) {
        font-weight: 600;
        letter-spacing: var(--boxel-lsp-sm);
      }

      .content > :deep(*) {
        margin-top: 0;
        margin-bottom: 0;
      }
      .content > :deep(* + *) {
        margin-top: var(--boxel-sp);
      }

      .error-container {
        display: grid;
        grid-template-columns: auto 1fr auto;
        gap: var(--boxel-sp-xs);
        padding: var(--boxel-sp-xs) var(--boxel-sp-sm);
        background-color: var(--boxel-danger);
        color: var(--boxel-light);
        font: 600 var(--boxel-font-sm);
        letter-spacing: var(--boxel-lsp);
      }
      .error-icon {
        --icon-background-color: var(--boxel-light);
        --icon-color: var(--boxel-danger);
        margin-top: var(--boxel-sp-5xs);
      }
      .error-message {
        align-self: center;
        overflow: hidden;
        word-wrap: break-word;
        overflow-wrap: break-word;
      }
      .retry-button {
        --boxel-button-padding: var(--boxel-sp-5xs) var(--boxel-sp-xs);
        --boxel-button-min-height: max-content;
        --boxel-button-min-width: max-content;
        border-color: var(--boxel-light);
      }

      .items {
        color: var(--boxel-dark);
        display: flex;
        flex-wrap: wrap;
        gap: var(--boxel-sp-xxs);
      }

      :deep(.preview-code) {
        --spacing: var(--boxel-sp-sm);
        --fill-container-spacing: calc(
          -1 * var(--ai-assistant-message-padding)
        );
        margin: var(--boxel-sp) var(--fill-container-spacing) 0
          var(--fill-container-spacing);
        padding: var(--spacing) 0;
        background-color: var(--boxel-dark);
      }

      :deep(.preview-code.code-block) {
        position: relative;
        padding-top: var(--boxel-sp-xxxl);
      }

      :deep(.monaco-container) {
        height: var(--monaco-container-height);
        min-height: 7rem;
        max-height: 30vh;
      }

      /*
        This filter is a best-effort approximation of a good looking dark theme that is a function of the white theme that
        we use for code previews in the AI panel. While Monaco editor does support multiple themes, it does not support
        monaco instances with different themes *on the same page*. This is why we are using a filter to approximate the
        dark theme. More details here: https://github.com/Microsoft/monaco-editor/issues/338 (monaco uses global style tags
        with hardcoded colors; any instance will override the global style tag, making all code editors look the same,
        effectively disabling multiple themes to be used on the same page)
      */
      :global(.preview-code .monaco-editor) {
        filter: invert(1) hue-rotate(151deg) brightness(0.8) grayscale(0.1);
      }

      /* we are cribbing the boxel-ui style here as we have a rather 
      awkward way that we insert the copy button */
      :deep(.code-copy-button) {
        --spacing: calc(1rem / 1.333);

        position: absolute;
        top: var(--boxel-sp);
        left: var(--boxel-sp-lg);
        color: var(--boxel-highlight);
        background: none;
        border: none;
        font: 600 var(--boxel-font-xs);
        padding: 0;
        margin-bottom: var(--spacing);
        display: grid;
        grid-template-columns: auto 1fr;
        gap: var(--spacing);
        letter-spacing: var(--boxel-lsp-xs);
        justify-content: center;
        height: min-content;
        align-items: center;
        white-space: nowrap;
        min-height: var(--boxel-button-min-height);
        min-width: var(--boxel-button-min-width, 5rem);
      }
      :deep(.code-copy-button .copy-text) {
        color: transparent;
      }
      :deep(.code-copy-button .copy-text:hover) {
        color: var(--boxel-highlight);
      }
    </style>
  </template>

  editorDisplayOptions: MonacoEditorOptions = {
    wordWrap: 'on',
    wrappingIndent: 'indent',
    fontWeight: 'bold',
    scrollbar: {
      alwaysConsumeMouseWheel: false,
    },
  };

  private get isAvatarAnimated() {
    return this.args.isStreaming && !this.args.errorMessage;
  }

  private get items() {
    return [
      ...(this.args.resources?.cards ?? []),
      ...(this.args.resources?.files ?? []),
    ];
  }
}

interface AiAssistantConversationSignature {
  Element: HTMLDivElement;
  Args: {
    setScrollPosition: (args: { isBottom: boolean }) => void;
    registerConversationScroller: (
      isScrollable: () => boolean,
      scrollToBottom: () => void,
    ) => void;
  };
  Blocks: {
    default: [];
  };
}

const AiAssistantConversation: TemplateOnlyComponent<AiAssistantConversationSignature> =
  <template>
    <div
      {{ScrollPosition
        setScrollPosition=@setScrollPosition
        registerConversationScroller=@registerConversationScroller
      }}
      class='ai-assistant-conversation'
      data-test-ai-assistant-conversation
    >
      {{yield}}
    </div>
    <style scoped>
      .ai-assistant-conversation {
        display: flex;
        flex-direction: column;
        padding: 0 var(--boxel-sp);
        overflow-y: auto;
      }
    </style>
  </template>;

export { AiAssistantConversation };
