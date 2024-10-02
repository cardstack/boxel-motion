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
    class='lucide lucide-rugby'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M15.7 2.3c-.2-.2-.9-.4-1.7-.3a4.6 4.6 0 0 0-3.7 5.7c.3.2.9.4 1.7.3a4.6 4.6 0 0 0 3.7-5.7M20 12H4'
    /><rect width='4' height='6' x='2' y='16' rx='1' /><path d='M4 2v14' /><rect
      width='4'
      height='6'
      x='18'
      y='16'
      rx='1'
    /><path d='M20 2v14' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'rugby';
export default IconComponent;
