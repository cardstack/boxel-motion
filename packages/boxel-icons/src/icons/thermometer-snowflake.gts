// This file is auto-generated by 'pnpm rebuild:all'
import type { TemplateOnlyComponent } from '@ember/component/template-only';

import type { Signature } from '../types.ts';

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
    class='lucide lucide-thermometer-snowflake'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M2 12h10M9 4v16M3 9l3 3-3 3M12 6 9 9 6 6M6 18l3-3 1.5 1.5M20 4v10.54a4 4 0 1 1-4 0V4a2 2 0 0 1 4 0Z'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'thermometer-snowflake';
export default IconComponent;
