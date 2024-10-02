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
    class='lucide lucide-vibrate'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='m2 8 2 2-2 2 2 2-2 2M22 8l-2 2 2 2-2 2 2 2' /><rect
      width='8'
      height='14'
      x='8'
      y='5'
      rx='1'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'vibrate';
export default IconComponent;
