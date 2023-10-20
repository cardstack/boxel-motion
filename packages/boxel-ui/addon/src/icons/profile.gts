// This file is auto-generated by 'pnpm rebuild:icons'
import type { TemplateOnlyComponent } from '@ember/component/template-only';

import type { Signature } from './types.ts';

const IconComponent: TemplateOnlyComponent<Signature> = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    width='60'
    height='60'
    viewBox='0 0 60 60'
    ...attributes
  ><rect width='60' height='60' fill='#afafb7' rx='30' /><g
      style='opacity:.5;fill:none;stroke:#fff;stroke-linecap:round;stroke-linejoin:round;stroke-width:3.5'
      transform='translate(17.297 16.055)'
    ><path
        d='M25.279 28.89v-3.21a6.371 6.371 0 0 0-6.32-6.42H6.32A6.371 6.371 0 0 0 0 25.68v3.21'
      /><circle cx='12.64' cy='6.32' r='6.32' /></g></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'Profile';
export default IconComponent;
