// This file is auto-generated by 'pnpm rebuild:icons'
import type { TemplateOnlyComponent } from '@ember/component/template-only';

import type { Signature } from './types.ts';

const IconComponent: TemplateOnlyComponent<Signature> = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    width='28'
    height='20'
    fill='var(--icon-color, #000)'
    stroke='var(--icon-color, #000)'
    stroke-width='7'
    viewBox='0 0 256 120'
    ...attributes
  ><path
      d='M83.4 75.2 119.6 39v148.2c0 4.6 3.8 8.4 8.4 8.4s8.4-3.8 8.4-8.4V39l36.2 36.2c3.3 3.3 8.6 3.3 11.9 0 1.6-1.6 2.5-3.8 2.5-5.9s-.8-4.3-2.5-5.9L134 12.8a8.39 8.39 0 0 0-11.9 0L71.5 63.3c-3.3 3.3-3.3 8.6 0 11.9s8.6 3.3 11.9 0z'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'Send';
export default IconComponent;
