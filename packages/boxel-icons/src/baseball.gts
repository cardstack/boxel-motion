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
    class='lucide lucide-baseball'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M2 12c5.5 0 10-4.5 10-10' /><circle cx='12' cy='12' r='10' /><path
      d='M22 12c-5.5 0-10 4.5-10 10M8 11.5l-1.5-2M11.5 8l-2-1.5M14.5 17.5l-2-1.5M17.5 14.5l-1.5-2'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'baseball';
export default IconComponent;
