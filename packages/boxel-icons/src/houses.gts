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
    class='lucide lucide-houses'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M6 17H3c-.6 0-1-.4-1-1V8.5L8 4l10 7.5V19c0 .6-.4 1-1 1H7c-.6 0-1-.4-1-1v-7.5L16 4l6 4.5V16c0 .6-.4 1-1 1h-3'
    /><path d='M10 20v-6h4v6' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'houses';
export default IconComponent;
