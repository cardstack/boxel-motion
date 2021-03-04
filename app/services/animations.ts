import Service from '@ember/service';

import { scheduleOnce } from '@ember/runloop';
import SpriteModifier from '../modifiers/sprite';
import SpriteTree from '../models/sprite-tree';
import AnimationContext from '../components/animation-context';
import { taskFor } from 'ember-concurrency-ts';
import TransitionRunner from 'animations/models/transition-runner';

export default class AnimationsService extends Service {
  contexts: Set<AnimationContext> = new Set();
  spriteTree = new SpriteTree();
  freshlyAdded: Set<SpriteModifier> = new Set();
  freshlyRemoved: Set<SpriteModifier> = new Set();

  possiblyFarMatchingSpriteModifiers: Set<SpriteModifier> = new Set();

  registerContext(context: AnimationContext): void {
    this.contexts.add(context);
    this.spriteTree.addAnimationContext(context);
    scheduleOnce('afterRender', this, 'handleFarMatching');
  }

  unregisterContext(context: AnimationContext): void {
    let contextDescendants = this.spriteTree.descendantsOf(context);
    for (let contextDescendant of contextDescendants) {
      if (contextDescendant instanceof SpriteModifier) {
        let spriteModifier = contextDescendant as SpriteModifier;
        this.possiblyFarMatchingSpriteModifiers.add(spriteModifier);
      }
    }
    this.contexts.delete(context);
    this.spriteTree.removeAnimationContext(context);
  }

  registerSpriteModifier(spriteModifier: SpriteModifier): void {
    this.spriteTree.addSpriteModifier(spriteModifier);
    this.freshlyAdded.add(spriteModifier);
  }

  unregisterSpriteModifier(spriteModifier: SpriteModifier): void {
    this.spriteTree.removeSpriteModifier(spriteModifier);
    this.freshlyRemoved.add(spriteModifier);
  }

  notifyRemovedSpriteModifier(spriteModifier: SpriteModifier): void {
    this.possiblyFarMatchingSpriteModifiers.add(spriteModifier);
    scheduleOnce('afterRender', this, 'handleFarMatching');
  }

  handleFarMatching(): void {
    console.log('AnimationsService#handleFarMatching()');
    this.contexts.forEach((context) =>
      context.handleFarMatching(this.possiblyFarMatchingSpriteModifiers)
    );

    this.possiblyFarMatchingSpriteModifiers.clear();
  }

  runTransition(animationContext: AnimationContext): void {
    let transitionRunner = new TransitionRunner(
      animationContext,
      this.spriteTree
    );
    let task = taskFor(transitionRunner.maybeTransitionTask);
    task.perform(animationContext);
  }
}

declare module '@ember/service' {
  interface Registry {
    animations: AnimationsService;
  }
}
