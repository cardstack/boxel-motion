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
    class='lucide lucide-hotel'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M10 22v-6.57M12 11h.01M12 7h.01M14 15.43V22M15 16a5 5 0 0 0-6 0M16 11h.01M16 7h.01M8 11h.01M8 7h.01'
    /><rect width='16' height='20' x='4' y='2' rx='2' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'hotel';
export default IconComponent;
