import Component from '@glimmer/component';

interface Signature {
  Element: HTMLDetailsElement;
  Blocks: {
    title: [];
    content: [];
  };
}

export default class AccordionItem extends Component<Signature> {
  <template>
    <details class='accordion-item'>
      <summary class='title'>
        {{yield to='title'}}
      </summary>
      <div class='content'>
        {{yield to='content'}}
      </div>
    </details>
    <style>
      .accordion-item {
        --accordion-item-closed-min-height: 40px;
        --accordion-item-open-min-height: 500px;
        --accordion-item-border: var(--boxel-border);
        --accordion-item-title-font: 700 var(--boxel-font);
        --accordion-item-title-letter-spacing: var(--boxel-lsp-xs);
        --accordion-item-title-padding: var(--boxel-sp-xs);
        --accordion-item-content-padding: var(--boxel-sp-xs);

        min-height: var(--accordion-item-closed-min-height);
        transition: min-height var(--boxel-transition);
      }
      .accordion-item[open] {
        min-height: var(--accordion-item-open-min-height);
      }
      .accordion-item > .content {
        height: 0;
        transition: min-height var(--boxel-transition);
      }
      .accordion-item[open] > .content {
        min-height: max-content;
      }
      .title {
        padding: var(--accordion-item-title-padding);
        font: var(--accordion-item-title-font);
        letter-spacing: var(--accordion-item-title-letter-spacing);
      }
      .title:hover {
        cursor: pointer;
      }
      ::marker {
        display: none;
        content: '';
      }
      .content {
        padding: var(--accordion-item-content-padding);
        border-top: var(--accordion-item-border);
      }
      .accordion-item + .accordion-item {
        border-top: var(--accordion-item-border);
      }
    </style>
  </template>
}
