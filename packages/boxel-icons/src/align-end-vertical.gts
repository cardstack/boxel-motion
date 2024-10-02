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
    class='lucide lucide-align-end-vertical'
    viewBox='0 0 24 24'
    ...attributes
  ><rect width='16' height='6' x='2' y='4' rx='2' /><rect
      width='9'
      height='6'
      x='9'
      y='14'
      rx='2'
    /><path d='M22 22V2' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'align-end-vertical';
export default IconComponent;
