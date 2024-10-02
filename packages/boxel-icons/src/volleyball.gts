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
    class='lucide lucide-volleyball'
    viewBox='0 0 24 24'
    ...attributes
  ><circle cx='12' cy='12' r='10' /><path
      d='M6.3 3.8a16.55 16.55 0 0 0 1.9 11.5M20.7 17a12.8 12.8 0 0 0-8.7-5 13.3 13.3 0 0 1 0-10'
    /><path
      d='M22 11.1c-.8-.6-1.7-1.3-2.6-1.8-3-1.7-6.1-2.5-8.3-2.2M7.8 21.1c1-.4 1.9-.8 2.9-1.4 3-1.7 5.2-4 6.1-6.1M12 12a12.6 12.6 0 0 1-8.7 5'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'volleyball';
export default IconComponent;
