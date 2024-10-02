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
    class='lucide lucide-soap-bar'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M11.3 2.7c.9-.9 2.5-.9 3.4 0l5.6 5.6c.9.9.9 2.5 0 3.4l-8.6 8.6c-.9.9-2.5.9-3.4 0l-5.6-5.6c-.9-.9-.9-2.5 0-3.4Z'
    /><path d='m13 7-6 6 3 3 6-6Z' /><circle
      cx='20.5'
      cy='17.5'
      r='.5'
    /><circle cx='17.5' cy='21.5' r='.5' /><path d='M22 22h.01' /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'soap-bar';
export default IconComponent;
