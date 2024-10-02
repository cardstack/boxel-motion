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
    class='lucide lucide-goal'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M12 13V2l8 4-8 4' /><path
      d='M20.561 10.222a9 9 0 1 1-12.55-5.29'
    /><path d='M8.002 9.997a5 5 0 1 0 8.9 2.02' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'goal';
export default IconComponent;
