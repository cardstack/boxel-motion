import Component from '@glimmer/component';
import { action } from '@ember/object';
import Changeset from 'animations/models/changeset';
import Sprite, { SpriteType } from 'animations/models/sprite';
import LinearBehavior from 'animations/behaviors/linear';

export default class AccordionPanel extends Component {
  @action async resizePanels(changeset: Changeset) {
    let duration = 320;
    let { context } = changeset;
    let bodies = changeset.spritesFor({
      type: SpriteType.Kept,
      role: 'accordion-panel-body',
    });
    let hiddenPanel: Sprite | undefined;

    let hiddenPanelContentGroup = changeset.spritesFor({
      type: SpriteType.Removed,
      role: 'accordion-panel-content',
    });
    if (hiddenPanelContentGroup.size) {
      hiddenPanel = [...hiddenPanelContentGroup][0];
    }

    let spritesToAnimate = [];

    if (hiddenPanel) {
      context.appendOrphan(hiddenPanel);
      hiddenPanel.lockStyles();
      hiddenPanel.element.style.top = '70px';
      hiddenPanel.element.style.left = '0px';

      hiddenPanel.setupAnimation('size', {
        startWidth: hiddenPanel.element.clientWidth,
        startHeight: hiddenPanel.element.clientHeight,
        endWidth: hiddenPanel.element.clientWidth,
        duration,
        behavior: new LinearBehavior(),
      });
      spritesToAnimate.push(hiddenPanel);
    }

    if (bodies.size) {
      for (let sprite of [...bodies]) {
        sprite.setupAnimation('size', {
          startHeight: sprite.initialBounds?.element.height,
          endHeight: sprite.finalBounds?.element.height,
          duration,
          behavior: new LinearBehavior(),
        });
        spritesToAnimate.push(sprite);
      }
    }

    await Promise.all(
      spritesToAnimate.map((sprite) => sprite.startAnimation().finished)
    );
  }
}
