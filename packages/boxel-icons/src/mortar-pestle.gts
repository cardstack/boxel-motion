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
    class='lucide lucide-mortar-pestle'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M22 4a2 2 0 0 0-3-1.7l-8.5 5.1A3 3 0 0 0 12 13c.8 0 1.5-.3 2-.8l7.3-6.7c.4-.4.7-.9.7-1.5'
    /><path d='M22 12a10 10 0 0 1-20 0' /><path
      d='M11.1 7C6 7.2 2 9.4 2 12c0 2.8 4.5 5 10 5s10-2.2 10-5c0-1.5-1.4-2.9-3.6-3.8'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'mortar-pestle';
export default IconComponent;
