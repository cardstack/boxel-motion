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
    class='lucide lucide-soccer-ball'
    viewBox='0 0 24 24'
    ...attributes
  ><circle cx='12' cy='12' r='10' /><path
      d='M11.9 6.7s-3 1.3-5 3.6c0 0 0 3.6 1.9 5.9 0 0 3.1.7 6.2 0 0 0 1.9-2.3 1.9-5.9 0 .1-2-2.3-5-3.6M11.9 6.7V2M16.9 10.4s3-1.4 4.5-1.6M15 16.3s1.9 2.7 2.9 3.7M8.8 16.3S6.9 19 6 20'
    /><path d='M2.6 8.7C4 9 7 10.4 7 10.4' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'soccer-ball';
export default IconComponent;
