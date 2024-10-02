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
    class='lucide lucide-lamp-desk'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='m14 5-3 3 2 7 8-8-7-2Z' /><path d='m14 5-3 3-3-3 3-3 3 3Z' /><path
      d='M9.5 6.5 4 12l3 6M3 22v-2c0-1.1.9-2 2-2h4a2 2 0 0 1 2 2v2H3Z'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'lamp-desk';
export default IconComponent;
