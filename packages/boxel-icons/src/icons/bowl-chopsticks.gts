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
    class='lucide lucide-bowl-chopsticks'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='m13 2-3 11M22 2l-8 11' /><ellipse
      cx='12'
      cy='12'
      rx='10'
      ry='5'
    /><path d='M22 12a10 10 0 0 1-20 0' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'bowl-chopsticks';
export default IconComponent;
