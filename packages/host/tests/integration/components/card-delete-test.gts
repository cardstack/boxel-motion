import { module, test } from 'qunit';
import GlimmerComponent from '@glimmer/component';
import { setupRenderingTest } from 'ember-qunit';
import { baseRealm } from '@cardstack/runtime-common';
import { Realm } from '@cardstack/runtime-common/realm';
import { Loader } from '@cardstack/runtime-common/loader';
import OperatorMode from '@cardstack/host/components/operator-mode/container';
import CardPrerender from '@cardstack/host/components/card-prerender';
import { renderComponent } from '../../helpers/render-component';
import {
  testRealmURL,
  setupCardLogs,
  setupLocalIndexing,
  setupOnSave,
  setupServerSentEvents,
  TestRealmAdapter,
  TestRealm,
  type TestContextWithSSE,
} from '../../helpers';
import { waitUntil, waitFor, click, focus } from '@ember/test-helpers';
import type LoaderService from '@cardstack/host/services/loader-service';
import OperatorModeStateService from '@cardstack/host/services/operator-mode-state-service';
import type CardService from '@cardstack/host/services/card-service';
import percySnapshot from '@percy/ember';
import { Card } from 'https://cardstack.com/base/card-api';

let loader: Loader;
let cardApi: typeof import('https://cardstack.com/base/card-api');
let setCardInOperatorModeState: (
  leftCards: string[],
  rightCards?: string[],
) => Promise<void>;

module('Integration | card-delete', function (hooks) {
  let adapter: TestRealmAdapter;
  let realm: Realm;
  let noop = () => {};
  async function loadCard(url: string): Promise<Card> {
    let { createFromSerialized, recompute } = cardApi;
    let result = await realm.searchIndex.card(new URL(url));
    if (!result || result.type === 'error') {
      throw new Error(
        `cannot get instance ${url} from the index: ${
          result ? result.error.detail : 'not found'
        }`,
      );
    }
    let card = await createFromSerialized<typeof Card>(
      result.doc.data,
      result.doc,
      new URL(url),
      loader,
    );
    await recompute(card, { loadFields: true });
    return card;
  }
  setupRenderingTest(hooks);
  hooks.beforeEach(async function () {
    loader = (this.owner.lookup('service:loader-service') as LoaderService)
      .loader;
    cardApi = await loader.import(`${baseRealm.url}card-api`);
  });
  setupLocalIndexing(hooks);
  setupOnSave(hooks);
  setupCardLogs(
    hooks,
    async () => await loader.import(`${baseRealm.url}card-api`),
  );
  setupServerSentEvents(hooks);
  hooks.afterEach(async function () {
    localStorage.removeItem('recent-cards');
  });

  hooks.beforeEach(async function () {
    localStorage.removeItem('recent-cards');

    setCardInOperatorModeState = async (
      leftCards: string[],
      rightCards: string[] = [],
    ) => {
      let operatorModeStateService = this.owner.lookup(
        'service:operator-mode-state-service',
      ) as OperatorModeStateService;

      let stacks = [
        leftCards.map((url) => ({
          type: 'card' as 'card',
          id: url,
          format: 'isolated' as 'isolated',
        })),
        rightCards.map((url) => ({
          type: 'card' as 'card',
          id: url,
          format: 'isolated' as 'isolated',
        })),
      ].filter((a) => a.length > 0);
      await operatorModeStateService.restore({ stacks });
    };
    adapter = new TestRealmAdapter({
      'pet.gts': `
        import { contains, field, Component, Card } from "https://cardstack.com/base/card-api";
        import StringCard from "https://cardstack.com/base/string";

        export class Pet extends Card {
          static displayName = 'Pet';
          @field firstName = contains(StringCard);
          @field title = contains(StringCard, {
            computeVia: function (this: Pet) {
              return this.firstName;
            },
          });
          static isolated = class Isolated extends Component<typeof this> {
            <template>
              <h2 data-test-pet={{@model.firstName}}><@fields.firstName/></h2>
              <@fields.pet/>
            </template>
          }
          static embedded = class Embedded extends Component<typeof this> {
            <template>
              <h3 data-test-pet={{@model.firstName}}><@fields.name/></h3>
            </template>
          }
        }
      `,
      'index.json': {
        data: {
          type: 'card',
          meta: {
            adoptsFrom: {
              module: 'https://cardstack.com/base/cards-grid',
              name: 'CardsGrid',
            },
          },
        },
      },
      'Pet/mango.json': {
        data: {
          type: 'card',
          attributes: {
            firstName: 'Mango',
          },
          meta: {
            adoptsFrom: {
              module: '../pet',
              name: 'Pet',
            },
          },
        },
      },
      'Pet/vangogh.json': {
        data: {
          type: 'card',
          attributes: {
            firstName: 'Van Gogh',
          },
          meta: {
            adoptsFrom: {
              module: '../pet',
              name: 'Pet',
            },
          },
        },
      },
      '.realm.json': {
        name: 'Test Workspace 1',
        backgroundURL:
          'https://i.postimg.cc/VNvHH93M/pawel-czerwinski-Ly-ZLa-A5jti-Y-unsplash.jpg',
        iconURL: 'https://i.postimg.cc/L8yXRvws/icon.png',
      },
    });

    realm = await TestRealm.createWithAdapter(adapter, loader, this.owner, {
      realmURL: testRealmURL,
    });
    await realm.ready;

    let cardService = this.owner.lookup('service:card-service') as CardService;
    // the copy button only appears after this service has loaded,
    // so let's just wait for it here
    await cardService.ready;
  });

  test<TestContextWithSSE>('can delete a card from the index card stack item', async function (assert) {
    assert.expect(4);
    let expectedEvents = ['removed: Pet/mango.json', 'index: incremental'];
    await setCardInOperatorModeState([`${testRealmURL}index`]);
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await this.expectEvents(
      assert,
      realm,
      adapter,
      expectedEvents,
      async () => {
        await waitFor(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item="${testRealmURL}Pet/mango"]`,
        );
        await click(
          `[data-test-overlay-card="${testRealmURL}Pet/mango"] button.more-actions`,
        );
        //await percySnapshot(assert);
        await click('[data-test-boxel-menu-item-text="Delete"]');
        await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
        assert
          .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
          .containsText('Delete the card Mango?');
        //await percySnapshot(
          'Integration | card-delete | can delete a card from the index card stack item, modal',
        );
        await click('[data-test-confirm-delete-button]');
      },
    );
    await waitUntil(
      () =>
        document.querySelectorAll(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item]`,
        ).length === 1,
    );
    let notFound = await adapter.openFile('Pet/mango.json');
    assert.strictEqual(notFound, undefined, 'file ref does not exist');
  });

  test<TestContextWithSSE>('can cancel delete', async function (assert) {
    await setCardInOperatorModeState([`${testRealmURL}index`]);
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await waitFor(
      `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item="${testRealmURL}Pet/mango"]`,
    );
    await click(
      `[data-test-overlay-card="${testRealmURL}Pet/mango"] button.more-actions`,
    );
    await click('[data-test-boxel-menu-item-text="Delete"]');
    await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
    assert
      .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
      .containsText('Delete the card Mango?');
    await click('[data-test-confirm-cancel-button]');
    await waitUntil(
      () =>
        !document.querySelector(
          '[data-test-delete-modal="${testRealmURL}Pet/mango"]',
        ),
    );
    fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
  });

  test<TestContextWithSSE>('can delete a card stack item in non-edit mode', async function (assert) {
    assert.expect(6);
    let expectedEvents = ['removed: Pet/mango.json', 'index: incremental'];
    await setCardInOperatorModeState([
      `${testRealmURL}index`,
      `${testRealmURL}Pet/mango`,
    ]);
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await this.expectEvents(
      assert,
      realm,
      adapter,
      expectedEvents,
      async () => {
        await waitFor(`[data-test-operator-mode-stack="0"] [data-test-pet]`);
        assert
          .dom(
            `[data-test-operator-mode-stack="0"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
          )
          .exists();
        await click(
          `[data-test-stack-card="${testRealmURL}Pet/mango"] [data-test-more-options-button]`,
        );
        await click('[data-test-boxel-menu-item-text="Delete"]');
        await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
        assert
          .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
          .containsText('Delete the card Mango?');
        await click('[data-test-confirm-delete-button]');
      },
    );
    await waitUntil(
      () =>
        !document.querySelector(
          '[data-test-delete-modal="${testRealmURL}Pet/mango"]',
        ),
    );
    assert
      .dom(
        `[data-test-operator-mode-stack="0"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
      )
      .doesNotExist('stack item removed');
    let notFound = await adapter.openFile('Pet/mango.json');
    assert.strictEqual(notFound, undefined, 'file ref does not exist');
  });

  test<TestContextWithSSE>('can delete a card stack item in edit mode', async function (assert) {
    assert.expect(6);
    let expectedEvents = ['removed: Pet/mango.json', 'index: incremental'];
    await setCardInOperatorModeState([
      `${testRealmURL}index`,
      `${testRealmURL}Pet/mango`,
    ]);
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await this.expectEvents(
      assert,
      realm,
      adapter,
      expectedEvents,
      async () => {
        await waitFor(`[data-test-operator-mode-stack="0"] [data-test-pet]`);
        assert
          .dom(
            `[data-test-operator-mode-stack="0"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
          )
          .exists();
        await click(
          `[data-test-stack-card="${testRealmURL}Pet/mango"] [data-test-edit-button]`,
        );
        await click(
          `[data-test-stack-card="${testRealmURL}Pet/mango"] [data-test-more-options-button]`,
        );
        await click('[data-test-boxel-menu-item-text="Delete"]');
        await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
        assert
          .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
          .containsText('Delete the card Mango?');
        await click('[data-test-confirm-delete-button]');
      },
    );
    await waitUntil(
      () =>
        !document.querySelector(
          '[data-test-delete-modal="${testRealmURL}Pet/mango"]',
        ),
    );
    assert
      .dom(
        `[data-test-operator-mode-stack="0"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
      )
      .doesNotExist('stack item removed');
    let notFound = await adapter.openFile('Pet/mango.json');
    assert.strictEqual(notFound, undefined, 'file ref does not exist');
  });

  test<TestContextWithSSE>('can delete a card that appears in both stacks as a stack item', async function (assert) {
    assert.expect(8);
    let expectedEvents = ['removed: Pet/mango.json', 'index: incremental'];
    await setCardInOperatorModeState(
      [`${testRealmURL}index`, `${testRealmURL}Pet/mango`],
      [`${testRealmURL}index`, `${testRealmURL}Pet/mango`],
    );
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await this.expectEvents(
      assert,
      realm,
      adapter,
      expectedEvents,
      async () => {
        await waitFor(`[data-test-operator-mode-stack="0"] [data-test-pet]`);
        await waitFor(`[data-test-operator-mode-stack="1"] [data-test-pet]`);
        assert
          .dom(
            `[data-test-operator-mode-stack="0"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
          )
          .exists();
        assert
          .dom(
            `[data-test-operator-mode-stack="1"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
          )
          .exists();
        await click(
          `[data-test-operator-mode-stack="0"] [data-test-stack-card="${testRealmURL}Pet/mango"] [data-test-more-options-button]`,
        );
        await click('[data-test-boxel-menu-item-text="Delete"]');
        await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
        assert
          .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
          .containsText('Delete the card Mango?');
        await click('[data-test-confirm-delete-button]');
      },
    );
    await waitUntil(
      () =>
        !document.querySelector(
          '[data-test-delete-modal="${testRealmURL}Pet/mango"]',
        ),
    );
    assert
      .dom(
        `[data-test-operator-mode-stack="0"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
      )
      .doesNotExist('stack item removed');
    assert
      .dom(
        `[data-test-operator-mode-stack="1"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
      )
      .doesNotExist('stack item removed');
    let notFound = await adapter.openFile('Pet/mango.json');
    assert.strictEqual(notFound, undefined, 'file ref does not exist');
  });

  test<TestContextWithSSE>('can delete a card that appears in both stacks as an element of the index card', async function (assert) {
    assert.expect(4);
    let expectedEvents = ['removed: Pet/mango.json', 'index: incremental'];
    await setCardInOperatorModeState(
      [`${testRealmURL}index`],
      [`${testRealmURL}index`],
    );
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await this.expectEvents(
      assert,
      realm,
      adapter,
      expectedEvents,
      async () => {
        await waitFor(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item="${testRealmURL}Pet/mango"]`,
        );
        await waitFor(
          `[data-test-operator-mode-stack="1"] [data-test-cards-grid-item="${testRealmURL}Pet/mango"]`,
        );
        await click(
          `[data-test-operator-mode-stack="0"] [data-test-overlay-card="${testRealmURL}Pet/mango"] button.more-actions`,
        );
        await click('[data-test-boxel-menu-item-text="Delete"]');
        await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
        assert
          .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
          .containsText('Delete the card Mango?');
        await click('[data-test-confirm-delete-button]');
      },
    );
    await waitUntil(
      () =>
        document.querySelectorAll(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item]`,
        ).length === 1,
    );
    await waitUntil(
      () =>
        document.querySelectorAll(
          `[data-test-operator-mode-stack="1"] [data-test-cards-grid-item]`,
        ).length === 1,
    );
    let notFound = await adapter.openFile('Pet/mango.json');
    assert.strictEqual(notFound, undefined, 'file ref does not exist');
  });

  test<TestContextWithSSE>('can delete a card that appears in both stacks as an index item and an element of the index card', async function (assert) {
    assert.expect(6);
    let expectedEvents = ['removed: Pet/mango.json', 'index: incremental'];
    await setCardInOperatorModeState(
      [`${testRealmURL}index`],
      [`${testRealmURL}index`, `${testRealmURL}Pet/mango`],
    );
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await this.expectEvents(
      assert,
      realm,
      adapter,
      expectedEvents,
      async () => {
        await waitFor(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item="${testRealmURL}Pet/mango"]`,
        );
        await waitFor(`[data-test-operator-mode-stack="1"] [data-test-pet]`);
        assert
          .dom(
            `[data-test-operator-mode-stack="1"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
          )
          .exists();
        await click(
          `[data-test-operator-mode-stack="0"] [data-test-overlay-card="${testRealmURL}Pet/mango"] button.more-actions`,
        );
        await click('[data-test-boxel-menu-item-text="Delete"]');
        await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
        assert
          .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
          .containsText('Delete the card Mango?');
        await click('[data-test-confirm-delete-button]');
      },
    );
    await waitUntil(
      () =>
        !document.querySelector(
          '[data-test-delete-modal="${testRealmURL}Pet/mango"]',
        ),
    );
    await waitUntil(
      () =>
        document.querySelectorAll(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item]`,
        ).length === 1,
    );
    assert
      .dom(
        `[data-test-operator-mode-stack="1"] [data-test-stack-card="${testRealmURL}Pet/mango"]`,
      )
      .doesNotExist('stack item removed');
    let notFound = await adapter.openFile('Pet/mango.json');
    assert.strictEqual(notFound, undefined, 'file ref does not exist');
  });

  test<TestContextWithSSE>('can delete a card that is a recent item', async function (assert) {
    assert.expect(6);
    let expectedEvents = ['removed: Pet/mango.json', 'index: incremental'];

    // creates a recent item
    let operatorModeStateService = this.owner.lookup(
      'service:operator-mode-state-service',
    ) as OperatorModeStateService;
    let mango = await loadCard(`${testRealmURL}Pet/mango`);
    operatorModeStateService.addRecentCard(mango);

    await setCardInOperatorModeState([`${testRealmURL}index`]);
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await this.expectEvents(
      assert,
      realm,
      adapter,
      expectedEvents,
      async () => {
        await waitFor(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item="${testRealmURL}Pet/mango"]`,
        );
        await focus(`[data-test-search-input] input`);
        assert
          .dom(`[data-test-search-result="${testRealmURL}Pet/mango"]`)
          .exists();
        await click('[data-test-search-sheet-cancel-button]');
        await click(
          `[data-test-overlay-card="${testRealmURL}Pet/mango"] button.more-actions`,
        );
        await click('[data-test-boxel-menu-item-text="Delete"]');
        await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
        assert
          .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
          .containsText('Delete the card Mango?');
        await click('[data-test-confirm-delete-button]');
      },
    );
    await waitUntil(
      () =>
        document.querySelectorAll(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item]`,
        ).length === 1,
    );
    let notFound = await adapter.openFile('Pet/mango.json');
    assert.strictEqual(notFound, undefined, 'file ref does not exist');
    await focus(`[data-test-search-input] input`);
    assert
      .dom(`[data-test-search-result="${testRealmURL}Pet/mango"]`)
      .doesNotExist('recent item removed');
  });

  test<TestContextWithSSE>('can delete a card that is a selected item', async function (assert) {
    assert.expect(6);
    let expectedEvents = ['removed: Pet/mango.json', 'index: incremental'];
    await setCardInOperatorModeState(
      [`${testRealmURL}index`],
      [`http://localhost:4202/test/`],
    );
    await renderComponent(
      class TestDriver extends GlimmerComponent {
        <template>
          <OperatorMode @onClose={{noop}} />
          <CardPrerender />
        </template>
      },
    );
    let fileRef = await adapter.openFile('Pet/mango.json');
    assert.ok(fileRef, 'card instance exists in file system');
    await this.expectEvents(
      assert,
      realm,
      adapter,
      expectedEvents,
      async () => {
        await waitFor(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item]`,
        );
        await waitFor(
          `[data-test-operator-mode-stack="1"] [data-test-cards-grid-item]`,
        );
        await click(
          `[data-test-overlay-card="${testRealmURL}Pet/mango"] button.select`,
        );
        await click(
          `[data-test-overlay-card="${testRealmURL}Pet/vangogh"] button.select`,
        );
        assert
          .dom('[data-test-copy-button]')
          .containsText('Copy 2 Cards', 'button text is correct');
        await click(
          `[data-test-overlay-card="${testRealmURL}Pet/mango"] button.more-actions`,
        );
        await click('[data-test-boxel-menu-item-text="Delete"]');
        await waitFor(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`);
        assert
          .dom(`[data-test-delete-modal="${testRealmURL}Pet/mango"]`)
          .containsText('Delete the card Mango?');
        await click('[data-test-confirm-delete-button]');
      },
    );
    await waitUntil(
      () =>
        document.querySelectorAll(
          `[data-test-operator-mode-stack="0"] [data-test-cards-grid-item]`,
        ).length === 1,
    );
    let notFound = await adapter.openFile('Pet/mango.json');
    assert.strictEqual(notFound, undefined, 'file ref does not exist');
    assert
      .dom('[data-test-copy-button]')
      .containsText('Copy 1 Card', 'button text is correct');
  });
});
