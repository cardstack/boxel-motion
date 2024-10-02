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
    class='lucide lucide-iteration-ccw'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M20 10c0-4.4-3.6-8-8-8s-8 3.6-8 8 3.6 8 8 8h8' /><path
      d='m16 14 4 4-4 4'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'iteration-ccw';
export default IconComponent;
