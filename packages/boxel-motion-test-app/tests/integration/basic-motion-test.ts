import { render, click } from '@ember/test-helpers';
import { setupRenderingTest } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { module, test } from 'qunit';
import type { Changeset } from '@cardstack/boxel-motion/models/animator';
import type { AnimationDefinition } from '@cardstack/boxel-motion/models/orchestration';
import TweenBehavior from '@cardstack/boxel-motion/behaviors/tween';
import { tracked } from '@glimmer/tracking';

module('Integration | basic-motion', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    class Example {
      @tracked big = false;
      toggleBig = () => {
        this.big = !this.big;
      };
      transition = (changeset: Changeset): AnimationDefinition => {
        return {
          timeline: {
            type: 'parallel',
            animations: [
              {
                sprites: changeset.keptSprites,
                properties: {
                  height: {},
                },
                timing: {
                  behavior: new TweenBehavior(),
                  duration: 1000,
                },
              },
            ],
          },
        };
      };
    }

    (this as any).example = new Example();

    await render(hbs`
      <button data-toggle {{on "click" this.example.toggleBig}}>Toggle</button>
      <AnimationContext @use={{this.example.transition}}>
        {{#if this.example.big}}
          <div data-target style="height: 300px; width: 300px; background-color: red" {{sprite id="1"}}></div>
        {{else}}
          <div data-target style="height: 50px; width: 300px; background-color: red" {{sprite id="1"}}></div>
        {{/if}}
      </AnimationContext>
    `);

    assert.equal(
      getComputedStyle(this.element.querySelector('[data-target]')!).height,
      '50px'
    );

    await click('[data-toggle]');

    //let clock = new TestClock(); // remember min of all getAnimations() startTimes as the baseline for this Clock
    for (let a of document.getAnimations()) {
      a.pause();
      a.currentTime = 0;
    }

    //assert.pixels('[data-target]', 'height', 50);

    assert.equal(
      getComputedStyle(this.element.querySelector('[data-target]')!).height,
      '50px'
    );

    // clock.now = 500;

    // each animation gets set relative to the baseline time, so that if any
    // animations started later, they get a relatively smaller currentTime
    for (let a of document.getAnimations()) {
      a.currentTime = 500;
    }

    assert.equal(
      getComputedStyle(this.element.querySelector('[data-target]')!).height,
      '175px'
    );

    // clock
    for (let a of document.getAnimations()) {
      a.currentTime = 1000 - 1 / 60;
    }

    let expected = 50 + ((300 - 50) * (1000 - 1 / 60)) / 1000;

    assert.equal(
      getComputedStyle(this.element.querySelector('[data-target]')!).height,
      `${expected}px`
    );

    for (let a of document.getAnimations()) {
      a.currentTime = 1000;
    }

    assert.equal(
      getComputedStyle(this.element.querySelector('[data-target]')!).height,
      '300px'
    );
  });
});
