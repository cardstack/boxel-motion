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
    class='lucide lucide-hat-hard'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M10 6.3c-3.4.9-6 4-6 7.7v2M10 10V5c0-.6.4-1 1-1h2c.6 0 1 .4 1 1v5M20 16v-2c0-3.7-2.6-6.8-6-7.7'
    /><rect width='20' height='4' x='2' y='16' rx='1' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'hat-hard';
export default IconComponent;
