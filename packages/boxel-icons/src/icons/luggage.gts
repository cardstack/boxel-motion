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
    class='lucide lucide-luggage'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M6 20a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2'
    /><path d='M8 18V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v14M10 20h4' /><circle
      cx='16'
      cy='20'
      r='2'
    /><circle cx='8' cy='20' r='2' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'luggage';
export default IconComponent;
