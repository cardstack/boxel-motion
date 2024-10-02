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
    class='lucide lucide-layout-list'
    viewBox='0 0 24 24'
    ...attributes
  ><rect width='7' height='7' x='3' y='3' rx='1' /><rect
      width='7'
      height='7'
      x='3'
      y='14'
      rx='1'
    /><path d='M14 4h7M14 9h7M14 15h7M14 20h7' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'layout-list';
export default IconComponent;
