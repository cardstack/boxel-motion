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
    class='lucide lucide-flower-rose'
    viewBox='0 0 24 24'
    ...attributes
  ><path d='M14 6a4 4 0 1 1-2-3.46' /><circle cx='12' cy='6' r='2' /><path
      d='M10 6a4 4 0 0 1 8 0v2A6 6 0 0 1 6 8V6M12 14v8M12 22c-4.2 0-7-1.667-7-5 4.2 0 7 1.667 7 5M12 22c4.2 0 7-1.667 7-5-4.2 0-7 1.667-7 5'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'flower-rose';
export default IconComponent;
