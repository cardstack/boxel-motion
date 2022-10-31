import Controller from '@ember/controller';
import { Changeset } from 'animations-experiment/models/changeset';
import runAnimations from 'animations-experiment/utils/run-animations';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import LinearBehavior from 'animations-experiment/behaviors/linear';
import { AnimationDefinition } from 'animations-experiment/models/transition-runner';

export default class DoubleRenderController extends Controller {
  @tracked count = 0;
  @tracked isShowing = true;

  @action
  hide() {
    this.isShowing = false;
  }

  @action
  show() {
    this.isShowing = true;
  }

  @action
  increment() {
    this.count += 1;
  }

  transition(changeset: Changeset): AnimationDefinition {
    let { removedSprites, keptSprites, insertedSprites } = changeset;
    let duration = 3000;

    let timing = {
      behavior: new LinearBehavior(),
      duration,
    };

    return {
      timeline: {
        parallel: [
          {
            sprites: removedSprites,
            properties: {
              position: {
                startY: 0,
                startX: 0,
                endY: -200,
                endX: 0,
              },
            },
            timing,
          },
          {
            sprites: insertedSprites,
            properties: {
              position: {
                startY: -200,
              },
            },
            timing,
          },
          {
            sprites: keptSprites,
            properties: {
              position: {},
            },
            timing,
          },
        ],
      },
    } as AnimationDefinition;
  }
}
