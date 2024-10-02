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
    class='lucide lucide-elephant-face'
    viewBox='0 0 24 24'
    ...attributes
  ><path
      d='M11 10a4 4 0 0 0 4 4 2 2 0 0 1 0 4 7 7 0 0 1-2.8-.6c-.5-.2-.9 0-1 .6l-.1 1-.9.9c-.4.4-.3.9.2 1.2 1.4.6 3 .9 4.6.9 3.3 0 6-2.7 6-6V8a4 4 0 0 0-4-4h-4.6c-.7-1.2-2-2-3.4-2H6C4.3 2 3 3.3 3 5v1a7 7 0 0 0 7 7h2.4M15.5 10H15'
    /></svg>
</template>;

// @ts-expect-error this is the only way to set a name on a Template Only Component currently
IconComponent.name = 'elephant-face';
export default IconComponent;
