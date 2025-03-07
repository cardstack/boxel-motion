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
    class='lucide lucide-escalator-arrow-up-right'
    viewBox='0 0 24 24'
    ...attributes
  ><circle cx='9' cy='3' r='1' /><path
      d='M9 7v3M17 3c-.6 0-1.3.3-1.7.7L6 13H4a2 2 0 0 0 0 4h3c.6 0 1.3-.3 1.7-.7L18 7h2a2 2 0 0 0 0-4ZM22 13l-9 9M18 13h4v4'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'escalator-arrow-up-right';
export default IconComponent;
