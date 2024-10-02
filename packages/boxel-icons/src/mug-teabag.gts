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
    class='lucide lucide-mug-teabag'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M17 8h1a4 4 0 1 1 0 8h-1M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4ZM4 4a1 1 0 0 1 1-1 1 1 0 0 0 1-1M10 4a1 1 0 0 1 1-1 1 1 0 0 0 1-1M16 4a1 1 0 0 1 1-1 1 1 0 0 0 1-1M9 8v3'
    /><path d='M11 16v-3.5L9 11l-2 1.5V16Z' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'mug-teabag';
export default IconComponent;
