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
    class='lucide lucide-fan-handheld'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M3 4c0-.6.4-1 1-1a17.8 17.8 0 0 1 16.9 16.9c0 .6-.4 1-1 1.1H5c-1.1.1-2-.8-2-1.9ZM9.9 4.4 3 19M15.7 8.3 3.6 20.4M19.6 14.1 5 21'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'fan-handheld';
export default IconComponent;
