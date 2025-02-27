import { RealmPaths } from './paths';
import type { ResolvedCodeRef } from './code-ref';
import type { Format } from 'https://cardstack.com/base/card-api';

export const baseRealm = new RealmPaths(new URL('https://cardstack.com/base/'));

export const specRef: ResolvedCodeRef = {
  module: `${baseRealm.url}spec`,
  name: 'Spec',
};
export const baseCardRef: ResolvedCodeRef = {
  module: `${baseRealm.url}card-api`,
  name: 'CardDef',
};
export const baseFieldRef: ResolvedCodeRef = {
  module: `${baseRealm.url}card-api`,
  name: 'FieldDef',
};
export const skillCardRef: ResolvedCodeRef = {
  module: `${baseRealm.url}skill-card`,
  name: 'SkillCard',
};

export const isField = Symbol('cardstack-field');
export const primitive = Symbol('cardstack-primitive');

export const aiBotUsername = 'aibot';

export const CardContextName = 'card-context';
export const DefaultFormatsContextName = 'default-format-context';

export const PermissionsContextName = 'permissions-context';

export const CardURLContextName = 'card-url-context';

export const RealmURLContextName = 'realm-url-context';

export interface Permissions {
  readonly canRead: boolean;
  readonly canWrite: boolean;
}

export type { Format };

export const formats: Format[] = [
  'isolated',
  'embedded',
  'fitted',
  'atom',
  'edit',
];
