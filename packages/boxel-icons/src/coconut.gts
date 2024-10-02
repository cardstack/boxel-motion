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
    class='lucide lucide-coconut'
    viewBox='0 0 24 24'
    ...attributes
  ><ellipse cx='12' cy='9' rx='10' ry='7' /><path
      d='M2 9v3a10 10 0 0 0 20 0V9'
    /><ellipse cx='12' cy='9' rx='6' ry='3' /><path d='m14 8 6-6h2' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'coconut';
export default IconComponent;
