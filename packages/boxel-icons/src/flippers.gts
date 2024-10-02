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
    class='lucide lucide-flippers'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M20 17c0-4 2-7 2-13.5 0-.3-.2-.5-.5-.5C19 3 17 4 17 4s-2-1-4.5-1h-1C9 3 7 4 7 4S5 3 2.5 3c-.3 0-.5.2-.5.5C2 10 4 13 4 17'
    /><path d='M12 3v.5C12 10 10 13 10 17' /><rect
      width='6'
      height='7'
      x='4'
      y='14'
      rx='3'
    /><path d='M12 3.5C12 10 14 13 14 17' /><rect
      width='6'
      height='7'
      x='14'
      y='14'
      rx='3'
    /><path d='M7 4v6M17 4v6' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'flippers';
export default IconComponent;
