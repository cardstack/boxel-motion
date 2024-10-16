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
    class='lucide lucide-briefcase'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M16 20V4a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16' /><rect
      width='20'
      height='14'
      x='2'
      y='6'
      rx='2'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'briefcase';
export default IconComponent;
