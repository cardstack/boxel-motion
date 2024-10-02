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
    class='lucide lucide-forklift'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M12 12H5a2 2 0 0 0-2 2v5' /><circle cx='13' cy='19' r='2' /><circle
      cx='5'
      cy='19'
      r='2'
    /><path d='M8 19h3m5-17v17h6M6 12V7c0-1.1.9-2 2-2h3l5 5' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'forklift';
export default IconComponent;
