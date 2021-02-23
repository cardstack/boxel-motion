import Controller from '@ember/controller';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import exampleTransition from '../transitions/example';
export default class IndexController extends Controller {
  people = [
    { name: 'Alex', title: 'Developer', id: 1, bio: 'foo bar vaz' },
    { name: 'Luke', title: 'Engineering Manager', id: 2, bio: 'baz foo noo' }
  ];

  @tracked selectedPerson;
  // @tracked contextHasPadding = false;
  // @tracked showContentBeforeContext = false;
  // @tracked showContentBefore = false;
  // @tracked showSpriteA = true;
  // @tracked showSpriteB = true;
  // @tracked spriteCPosition = 0;
  // @tracked showContentAfter = false;
  // @action toggleSpritesAandB() {
  //   this.showSpriteA = !this.showSpriteA;
  //   this.showSpriteB = !this.showSpriteB;
  // }
  // @action moveSpriteC() {
  //   this.spriteCPosition = (this.spriteCPosition + 1) % 2;
  // }
  transition = exampleTransition;
}
