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
    class='lucide lucide-fire-extinguisher'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M15 6.5V3a1 1 0 0 0-1-1h-2a1 1 0 0 0-1 1v3.5M9 18h8M18 3h-3' /><path
      d='M11 3a6 6 0 0 0-6 6v11M5 13h4M17 10a4 4 0 0 0-8 0v10a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2Z'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'fire-extinguisher';
export default IconComponent;
