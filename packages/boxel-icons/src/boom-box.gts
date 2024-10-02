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
    class='lucide lucide-boom-box'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M4 9V5a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v4M8 8v1M12 8v1M16 8v1' /><rect
      width='20'
      height='12'
      x='2'
      y='9'
      rx='2'
    /><circle cx='8' cy='15' r='2' /><circle cx='16' cy='15' r='2' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'boom-box';
export default IconComponent;
