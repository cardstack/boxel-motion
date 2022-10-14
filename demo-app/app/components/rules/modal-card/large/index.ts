import Component from '@glimmer/component';
import { createRole, GROUP_TYPES } from '../../constants';

export default class LargeModalCard extends Component<{
  state: string;
  id: string;
}> {
  get cardRole() {
    return createRole({
      groupType: GROUP_TYPES.LARGE_MODAL_CARD,
      subType: 'card',
      state: this.args.state ?? 'none',
      id: this.args.id,
    });
  }

  get overlayRole() {
    return createRole({
      groupType: GROUP_TYPES.LARGE_MODAL_CARD,
      subType: 'overlay',
      state: this.args.state ?? 'none',
      id: this.args.id,
    });
  }
}
