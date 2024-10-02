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
    class='lucide lucide-feather-plus'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M2 7h6M5 4v6M5.1 17H14l8-8.2c-2.3-2.3-6.1-2.3-8.5 0L2.1 20M18 13H9.2'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'feather-plus';
export default IconComponent;
