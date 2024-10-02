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
    class='lucide lucide-razor-blade'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M22 8h-2V6H4v2H2v8h2v2h16v-2h2ZM6 11v2M10 12H6' /><circle
      cx='12'
      cy='12'
      r='2'
    /><path d='M18 12h-4M18 11v2' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'razor-blade';
export default IconComponent;
