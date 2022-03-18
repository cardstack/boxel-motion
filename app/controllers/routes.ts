import Controller from '@ember/controller';
import Sprite, { SpriteType } from '../models/sprite';
import Changeset from '../models/changeset';
import magicMove from 'animations/transitions/magic-move';
import { assert } from '@ember/debug';
import ContextAwareBounds from 'animations/models/context-aware-bounds';
import runAnimations from 'animations/utils/run-animations';
import SpringBehavior from 'animations/behaviors/spring';

const springBehavior = new SpringBehavior({
  overshootClamping: true,
  damping: 100,
});

export default class RoutesController extends Controller {
  async transition(changeset: Changeset): Promise<void> {
    let { removedSprites, keptSprites, insertedSprites, context } = changeset;

    assert('Context must always have currentBounds', context.currentBounds);

    if (keptSprites.size > 0) {
      let keptSprite = changeset.spriteFor({
        type: SpriteType.Kept,
      }) as Sprite;

      assert(
        'keptSprite always has a counterpart, initialBounds and finalBounds',
        keptSprite.counterpart &&
          keptSprite.initialBounds &&
          keptSprite.finalBounds
      );

      for (let removedSprite of removedSprites) {
        assert(
          'removedSprite must always have initialBounds',
          removedSprite.initialBounds
        );

        context.appendOrphan(removedSprite);
        // TODO: either don't compensate for the animation in lockStyles
        //  or take it into account when calculating the animation.
        removedSprite.lockStyles({
          left: 0,
          top: 0,
          width: removedSprite.initialBounds.element.width,
          height: removedSprite.initialBounds.element.height,
        });

        let moveLeft = keptSprite.id === 'route-content-other';

        let { x, y, width } = keptSprite.finalBounds.element;
        let finalElementBounds;
        if (moveLeft) {
          finalElementBounds = new DOMRect(
            x - width,
            y,
            removedSprite.initialBounds.element.width,
            removedSprite.initialBounds.element.height
          );
        } else {
          finalElementBounds = new DOMRect(
            x + width,
            y,
            removedSprite.initialBounds.element.width,
            removedSprite.initialBounds.element.height
          );
        }
        removedSprite.finalBounds = new ContextAwareBounds({
          element: finalElementBounds,
          contextElement: context.currentBounds,
        });

        let initialBounds = removedSprite.initialBounds.relativeToContext;
        let finalBounds = removedSprite.finalBounds.relativeToContext;

        removedSprite.setupAnimation('position', {
          startX: initialBounds.x,
          endX: finalBounds.x,
          behavior: springBehavior,
        });
      }

      magicMove(changeset, {
        behavior: springBehavior,
      });
    } else {
      let removedSprite = changeset.spriteFor({ type: SpriteType.Removed });
      let insertedSprite = changeset.spriteFor({ type: SpriteType.Inserted });

      assert(
        'removedSprite.initialWidth and insertedSprite.finalWidth are present',
        removedSprite?.initialWidth && insertedSprite?.finalWidth
      );

      context.appendOrphan(removedSprite);
      removedSprite.lockStyles();

      let moveLeft = insertedSprite?.id === 'route-content-other';

      removedSprite.setupAnimation('position', {
        endX: removedSprite.initialWidth * (moveLeft ? -1 : 1),
        behavior: springBehavior,
      });

      insertedSprite.setupAnimation('position', {
        startX: insertedSprite.finalWidth * (moveLeft ? 1 : -1),
        behavior: springBehavior,
      });
    }

    await runAnimations([
      ...removedSprites,
      ...keptSprites,
      ...insertedSprites,
    ]);
  }
}
