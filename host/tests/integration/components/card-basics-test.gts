import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { renderCard } from '../../helpers/render-component';
import { contains, field, Component, primitive } from 'runtime-spike/lib/card-api';
import StringCard from 'runtime-spike/lib/string';
import IntegerCard from 'runtime-spike/lib/integer';

module('Integration | card-basics', function (hooks) {
  setupRenderingTest(hooks);

  test('primitive field type checking', async function (assert) {
    class Person {
      @field firstName = contains(StringCard);
      @field title = contains(StringCard);
      @field number = contains(IntegerCard);

      static isolated = class Isolated extends Component<typeof this> {
        <template>{{@model.firstName}} {{@model.title}} {{@model.number}}</template>
      }
    }
    let card = new Person();
    card.firstName = 'arthur';
    card.number = 42;
    let readName: string = card.firstName;
    assert.strictEqual(readName, 'arthur');
    let readNumber: number = card.number;
    assert.strictEqual(readNumber, 42);
  });

  test('access @model for primitive and composite fields', async function (assert) {

    class Person {
      @field firstName = contains(StringCard);
      @field subscribers = contains(IntegerCard);
    }

    class Post {
      @field title = contains(StringCard);
      @field author = contains(Person);
      static isolated = class Isolated extends Component<typeof this> {
        <template>{{@model.title}} by {{@model.author.firstName}}, {{@model.author.subscribers}} subscribers</template>
      }
    }

    class HelloWorld extends Post {
      static data = { title: 'First Post', author: { firstName: 'Arthur', subscribers: 5 } }
    }

    await renderCard(HelloWorld, 'isolated');
    assert.strictEqual(this.element.textContent!.trim(), 'First Post by Arthur, 5 subscribers');
  });

  test('render primitive field', async function (assert) {
    class EmphasizedString {
      static [primitive]: string;
      static embedded = class Embedded extends Component<typeof this> {
        <template><em data-test="name">{{@model}}</em></template>
      }
    }

    class StrongInteger {
      static [primitive]: number;
      static embedded = class Embedded extends Component<typeof this> {
        <template><strong data-test="integer">{{@model}}</strong></template>
      }
    }

    class Person {
      @field firstName = contains(EmphasizedString);
      @field number = contains(StrongInteger);

      static embedded = class Embedded extends Component<typeof this> {
        <template><@fields.firstName /><@fields.number /></template>
      }
    }

    class Arthur extends Person {
      static data = { firstName: 'Arthur', number: 10 }
    }

    await renderCard(Arthur, 'embedded');
    assert.dom('[data-test="name"]').containsText('Arthur');
    assert.dom('[data-test="integer"]').containsText('10');
  });

  test('render whole composite field', async function (assert) {
    class Person {
      @field firstName = contains(StringCard);
      @field title = contains(StringCard);
      @field number = contains(IntegerCard);
      static embedded = class Embedded extends Component<typeof this> {
        <template><@fields.title/> <@fields.firstName /> <@fields.number /></template>
      }
    }

    class Post {
      @field author = contains(Person);
      static isolated = class Isolated extends Component<typeof this> {
        <template><div data-test><@fields.author /></div></template>
      }
    }

    class HelloWorld extends Post {
      static data = { author: { firstName: 'Arthur', title: 'Mr', number: 10 } }
    }

    await renderCard(HelloWorld, 'isolated');
    assert.dom('[data-test]').containsText('Mr Arthur 10');
  });

  test('render nested composite field', async function (assert) {
    class TestString {
      static [primitive]: string;
      static embedded = class Embedded extends Component<typeof this> {
        <template><em data-test="string">{{@model}}</em></template>
      }
    }

    class TestInteger {
      static [primitive]: number;
      static embedded = class Embedded extends Component<typeof this> {
        <template><strong data-test="integer">{{@model}}</strong></template>
      }
    }

    class Person {
      @field firstName = contains(TestString);
      @field number = contains(TestInteger);
    }

    class Post {
      @field author = contains(Person);
      static isolated = class Isolated extends Component<typeof this> {
        <template><@fields.author.firstName /><@fields.author.number /></template>
      }
    }

    class HelloWorld extends Post {
      static data = { author: { firstName: 'Arthur', number: 10 } }
    }

    await renderCard(HelloWorld, 'isolated');
    assert.dom('[data-test="string"]').containsText('Arthur');
    assert.dom('[data-test="integer"]').containsText('10');
  });

  test('render default templates', async function (assert) {
    class Person {
      @field firstName = contains(testString('first-name'));

      static embedded = class Embedded extends Component<typeof this> {
        <template><@fields.firstName /></template>
      }
    }

    class Post {
      @field title = contains(testString('title'));
      @field author = contains(Person);
    }

    class HelloWorld extends Post {
      static data = { title: 'First Post', author: { firstName: 'Arthur' } }
    }

    await renderCard(HelloWorld, 'isolated');

    assert.dom('[data-test="first-name"]').containsText('Arthur');
    assert.dom('[data-test="title"]').containsText('First Post');

  });

  test('can adopt a card', async function (assert) {
    class Animal {
      @field species = contains(testString('species'));
    }
    class Person extends Animal {
      @field firstName = contains(testString('first-name'));
      static embedded = class Embedded extends Component<typeof this> {
        <template><@fields.firstName /><@fields.species/></template>
      }
    }

    class Hassan extends Person {
      static data = { firstName: 'Hassan', species: 'Homo Sapiens' }
    }

    await renderCard(Hassan, 'embedded');
    assert.dom('[data-test="first-name"]').containsText('Hassan');
    assert.dom('[data-test="species"]').containsText('Homo Sapiens');
  });
});

function testString(label: string) {
  return class TestString {
    static [primitive]: string;
    static embedded = class Embedded extends Component<typeof this> {
      <template><em data-test={{label}}>{{@model}}</em></template>
    }
  }
}
