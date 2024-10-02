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
    class='lucide lucide-bed-bunk'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M2 22V2M2 5h18a2 2 0 0 1 2 2v15M6 5v5M2 10h20M2 14h20M22 19H2M6 14v5'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'bed-bunk';
export default IconComponent;
