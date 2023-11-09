import { module, test } from 'qunit';
import { setupRenderingTest } from 'test-app/tests/helpers';
import { click, fillIn, render, typeIn } from '@ember/test-helpers';
import { BoxelInput } from '@cardstack/boxel-ui/components';

module('Integration | Component | input', function (hooks) {
  setupRenderingTest(hooks);

  test('it passes through the value and does not render missing optional properties', async function (assert) {
    await render(<template>
      <BoxelInput data-test-input @value='hello' />
    </template>);

    assert.dom('[data-test-input]').hasValue('hello');

    assert.dom('[data-test-boxel-input-helper-text]').doesNotExist();
  });

  test('it returns values through onInput', async function (assert) {
    let value = 'yes';

    function onInput(newValue: string) {
      value = newValue;
    }

    await render(<template>
      <BoxelInput data-test-input @onInput={{onInput}} />
    </template>);
    await fillIn('[data-test-input]', 'no');

    assert.strictEqual(value, 'no');
  });

  test('it passes focus, blur, and keyPress events', async function (assert) {
    let focused = false;
    let blurred = false;
    let keyPressed = false;

    function onFocus() {
      focused = true;
    }

    function onBlur() {
      blurred = true;
    }

    function onKeyPress() {
      keyPressed = true;
    }

    await render(<template>
      <button>do nothing</button>
      <BoxelInput
        data-test-input
        @onFocus={{onFocus}}
        @onBlur={{onBlur}}
        @onKeyPress={{onKeyPress}}
      />
    </template>);

    await click('[data-test-input]');
    await click('button');
    await typeIn('[data-test-input]', 'key');

    assert.true(focused);
    assert.true(blurred);
    assert.true(keyPressed);
  });

  test('textarea @type produces a textarea', async function (assert) {
    await render(<template>
      <BoxelInput data-test-input @type='textarea' />
    </template>);

    assert.dom('[data-test-input]').hasTagName('textarea');
  });

  test('other @type passes through', async function (assert) {
    await render(<template>
      <BoxelInput data-test-input @type='number' />
    </template>);

    assert.dom('[data-test-input]').hasAttribute('type', 'number');
  });

  test('@helperText shows', async function (assert) {
    await render(<template>
      <BoxelInput data-test-input @helperText='help!' />
    </template>);

    assert.dom('*:has([data-test-input])').containsText('help!');
  });

  test('it indicates @optional status but @required takes priority', async function (assert) {
    await render(<template>
      <BoxelInput data-test-optional-input @optional={{true}} />
      <BoxelInput
        data-test-required-input
        @required={{true}}
        @optional={{true}}
      />
    </template>);

    assert.dom('*:has([data-test-optional-input])').containsText('Optional');

    assert
      .dom('*:has([data-test-required-input])')
      .doesNotContainText('Optional');
    assert.dom('[data-test-required-input]').hasAttribute('required');
  });
});
