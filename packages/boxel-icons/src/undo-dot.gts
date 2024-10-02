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
    class='lucide lucide-undo-dot'
    viewBox='0 0 24 24'
    ...attributes
  ><circle cx='12' cy='17' r='1' /><path d='M3 7v6h6' /><path
      d='M21 17a9 9 0 0 0-9-9 9 9 0 0 0-6 2.3L3 13'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'undo-dot';
export default IconComponent;
