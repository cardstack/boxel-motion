// @ts-ignore
import { precompileTemplate } from '@ember/template-compilation';
import { render, getContext } from '@ember/test-helpers';
import { ComponentLike } from '@glint/template';
import type {
  CardBase,
  Format,
  Field,
  CardContext,
} from 'https://cardstack.com/base/card-api';
import { baseRealm, Loader } from '@cardstack/runtime-common';

async function cardApi(
  loader: Loader
): Promise<typeof import('https://cardstack.com/base/card-api')> {
  return await loader.import(`${baseRealm.url}card-api`);
}

export async function renderComponent(C: ComponentLike) {
  await render(precompileTemplate(`<C/>`, { scope: () => ({ C }) }));
}

export async function renderCard(
  loader: Loader,
  card: CardBase,
  format: Format,
  field?: Field,
  context?: CardContext
) {
  let api = await cardApi(loader);
  await api.recompute(card, { recomputeAllFields: true });
  await renderComponent(api.getComponent(card, format, field, context));
  return (getContext() as { element: Element }).element;
}
