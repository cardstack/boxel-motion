// This file is auto-generated by 'pnpm rebuild:all'
import type { TemplateOnlyComponent } from '@ember/component/template-only';

import type { Signature } from './types.ts';

const IconComponent: TemplateOnlyComponent<Signature> = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    width='24'
    height='24'
    fill='none'
    stroke='currentColor'
    stroke-linecap='round'
    stroke-linejoin='round'
    stroke-width='2'
    class='lucide lucide-tab-text'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M8 8h6M8 12h8M8 16h6M4 20V6a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v14M22 20H2'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'tab-text';
export default IconComponent;
