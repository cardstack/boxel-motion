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
    class='lucide lucide-fence'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M4 3 2 5v15c0 .6.4 1 1 1h2c.6 0 1-.4 1-1V5ZM6 8h4M6 18h4M12 3l-2 2v15c0 .6.4 1 1 1h2c.6 0 1-.4 1-1V5ZM14 8h4M14 18h4M20 3l-2 2v15c0 .6.4 1 1 1h2c.6 0 1-.4 1-1V5Z'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'fence';
export default IconComponent;
