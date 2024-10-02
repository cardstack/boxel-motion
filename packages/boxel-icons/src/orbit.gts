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
    class='lucide lucide-orbit'
    viewBox='0 0 24 24'
    ...attributes
  ><circle cx='12' cy='12' r='3' /><circle cx='19' cy='5' r='2' /><circle
      cx='5'
      cy='19'
      r='2'
    /><path
      d='M10.4 21.9a10 10 0 0 0 9.941-15.416M13.5 2.1a10 10 0 0 0-9.841 15.416'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'orbit';
export default IconComponent;
