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
    class='lucide lucide-ice-skate'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M11 2v9M11 7 8 8M11 3 4 5v11a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2 3.08 3.08 0 0 0-1.8-2.8L11 11l-3 1M7 18v4M15 18v4M4 22h12c2.1 0 3.9-1.1 5-2.7'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'ice-skate';
export default IconComponent;
