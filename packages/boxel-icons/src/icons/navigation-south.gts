// This file is auto-generated by 'pnpm rebuild:all'
import type { TemplateOnlyComponent } from '@ember/component/template-only';

import type { Signature } from '../types.ts';

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
    class='icon icon-tabler icons-tabler-outline icon-tabler-navigation-south'
    viewBox='0 0 24 24'
    ...attributes
  ><path stroke='none' d='M0 0h24v24H0z' /><path
      d='M10 8.25c0 .414.336.75.75.75H13a1 1 0 0 0 1-1V7a1 1 0 0 0-1-1h-2a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h2.25a.75.75 0 0 1 .75.75M16 21l-4-8-4 8 4-2z'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'navigation-south';
export default IconComponent;
