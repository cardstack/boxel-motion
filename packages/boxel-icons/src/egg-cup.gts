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
    class='lucide lucide-egg-cup'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M18 11c0-3.3-2.7-9-6-9s-6 5.7-6 9M19 11a7 7 0 1 1-14 0ZM12 18v4M9 22h6'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'egg-cup';
export default IconComponent;
