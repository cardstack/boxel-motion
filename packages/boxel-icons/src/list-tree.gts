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
    class='lucide lucide-list-tree'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M21 12h-8M21 6H8M21 18h-8M3 6v4c0 1.1.9 2 2 2h3' /><path
      d='M3 10v6c0 1.1.9 2 2 2h3'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'list-tree';
export default IconComponent;
