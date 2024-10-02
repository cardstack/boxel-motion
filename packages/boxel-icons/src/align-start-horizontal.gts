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
    class='lucide lucide-align-start-horizontal'
    viewBox='0 0 24 24'
    ...attributes
  ><rect width='6' height='16' x='4' y='6' rx='2' /><rect
      width='6'
      height='9'
      x='14'
      y='6'
      rx='2'
    /><path d='M22 2H2' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'align-start-horizontal';
export default IconComponent;
