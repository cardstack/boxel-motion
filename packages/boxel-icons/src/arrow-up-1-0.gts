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
    class='lucide lucide-arrow-up-1-0'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='m3 8 4-4 4 4M7 4v16M17 10V4h-2M15 10h4' /><rect
      width='4'
      height='6'
      x='15'
      y='14'
      ry='2'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'arrow-up-1-0';
export default IconComponent;
