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
    class='lucide lucide-tire'
    viewBox='0 0 24 24'
    ...attributes
  ><circle cx='12' cy='12' r='10' /><circle cx='12' cy='12' r='2' /><circle
      cx='12'
      cy='12'
      r='6'
    /><path
      d='M12 14v4M10.1 12.62l-3.8 1.23M10.82 10.38 8.47 7.15M13.9 12.62l3.8 1.23M13.18 10.38l2.35-3.23'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'tire';
export default IconComponent;
