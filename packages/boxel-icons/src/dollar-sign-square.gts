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
    class='lucide lucide-dollar-sign-square'
    viewBox='0 0 24 24'
    ...attributes
  ><rect width='18' height='18' x='3' y='3' rx='2' /><path
      d='M12 17V7M16 8h-6a2 2 0 0 0 0 4h4a2 2 0 0 1 0 4H8'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'dollar-sign-square';
export default IconComponent;
