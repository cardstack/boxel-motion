import { service } from '@ember/service';
import { cached } from '@glimmer/tracking';

import ignore, { type Ignore } from 'ignore';

import isEqual from 'lodash/isEqual';
import merge from 'lodash/merge';

import {
  baseRealm,
  logger,
  baseCardRef,
  isCardResource,
  internalKeyFor,
  trimExecutableExtension,
  hasExecutableExtension,
  SupportedMimeType,
  loadCard,
  identifyCard,
  moduleFrom,
  isCardDef,
  IndexWriter,
  unixTime,
  type Batch,
  type LooseCardResource,
  type InstanceEntry,
  type ErrorEntry,
  type CodeRef,
  type RealmInfo,
  type IndexResults,
  type SingleCardDocument,
  type CardResource,
  type Relationship,
  type TextFileRef,
  type LastModifiedTimes,
} from '@cardstack/runtime-common';
import { Deferred } from '@cardstack/runtime-common/deferred';
import {
  CardError,
  isCardError,
  serializableError,
  type SerializedError,
} from '@cardstack/runtime-common/error';
import { cardTypeIcon } from '@cardstack/runtime-common/helpers';
import { RealmPaths, LocalPath } from '@cardstack/runtime-common/paths';
import { isIgnored } from '@cardstack/runtime-common/realm-index-updater';
import { type Reader, type Stats } from '@cardstack/runtime-common/worker';

import { CardDef } from 'https://cardstack.com/base/card-api';
import type * as CardAPI from 'https://cardstack.com/base/card-api';

import {
  type RenderCard,
  type Render,
  IdentityContextWithErrors,
} from '../services/render-service';

import type LoaderService from '../services/loader-service';
import type NetworkService from '../services/network';

const log = logger('current-run');
const perfLog = logger('index-perf');

interface CardType {
  refURL: string;
  codeRef: CodeRef;
  displayName: string;
}
type TypesWithErrors =
  | {
      type: 'types';
      types: CardType[];
    }
  | {
      type: 'error';
      error: SerializedError;
    };

export class CurrentRun {
  #typesCache = new WeakMap<typeof CardDef, Promise<TypesWithErrors>>();
  #indexingInstances = new Map<string, Promise<void>>();
  #reader: Reader;
  #indexWriter: IndexWriter;
  #batch: Batch | undefined;
  #realmPaths: RealmPaths;
  #ignoreData: Record<string, string>;
  #renderCard: RenderCard;
  #render: Render;
  #realmURL: URL;
  #realmInfo?: RealmInfo;
  readonly stats: Stats = {
    instancesIndexed: 0,
    modulesIndexed: 0,
    instanceErrors: 0,
    moduleErrors: 0,
    totalIndexEntries: 0,
  };
  @service private declare loaderService: LoaderService;
  @service private declare network: NetworkService;

  constructor({
    realmURL,
    reader,
    indexWriter,
    ignoreData = {},
    renderCard,
    render,
  }: {
    realmURL: URL;
    reader: Reader;
    indexWriter: IndexWriter;
    ignoreData?: Record<string, string>;
    renderCard: RenderCard;
    render: Render;
  }) {
    this.#indexWriter = indexWriter;
    this.#realmPaths = new RealmPaths(realmURL);
    this.#reader = reader;
    this.#realmURL = realmURL;
    this.#ignoreData = ignoreData;
    this.#renderCard = renderCard;
    this.#render = render;
  }

  static async fromScratch(
    current: CurrentRun,
    invalidateEntireRealm?: boolean,
  ): Promise<IndexResults> {
    let start = Date.now();
    log.debug(`starting from scratch indexing`);
    perfLog.debug(
      `starting from scratch indexing for realm ${current.realmURL.href}`,
    );

    current.#batch = await current.#indexWriter.createBatch(current.realmURL);
    let invalidations: URL[] = [];
    try {
      if (invalidateEntireRealm) {
        perfLog.debug(
          `flag was set to invalidate entire realm ${current.realmURL.href}, skipping invalidation discovery`,
        );
        let mtimesStart = Date.now();
        let filesystemMtimes = await current.#reader.mtimes();
        perfLog.debug(
          `time to get file system mtimes ${Date.now() - mtimesStart} ms`,
        );
        invalidations = Object.keys(filesystemMtimes)
          .filter(
            (url) =>
              // Only allow json and executable files to be invalidated so that we
              // don't end up with invalidated files that weren't meant to be indexed
              // (images, etc)
              url.endsWith('.json') || hasExecutableExtension(url),
          )
          .map((url) => new URL(url));
      } else {
        let mtimesStart = Date.now();
        let mtimes = await current.batch.getModifiedTimes();
        perfLog.debug(
          `completed getting index mtimes in ${Date.now() - mtimesStart} ms`,
        );
        let invalidateStart = Date.now();
        invalidations = (
          await current.discoverInvalidations(current.realmURL, mtimes)
        ).map((href) => new URL(href));
        perfLog.debug(
          `completed invalidations in ${Date.now() - invalidateStart} ms`,
        );
      }

      await current.whileIndexing(async () => {
        let visitStart = Date.now();
        for (let invalidation of invalidations) {
          await current.tryToVisit(invalidation);
        }
        perfLog.debug(`completed index visit in ${Date.now() - visitStart} ms`);
        let finalizeStart = Date.now();
        let { totalIndexEntries } = await current.batch.done();
        perfLog.debug(
          `completed index finalization in ${Date.now() - finalizeStart} ms`,
        );
        current.stats.totalIndexEntries = totalIndexEntries;
        log.debug(`completed from scratch indexing in ${Date.now() - start}ms`);
        perfLog.debug(
          `completed from scratch indexing for realm ${
            current.realmURL.href
          } in ${Date.now() - start} ms`,
        );
      });
    } catch (e: any) {
      console.error(
        `Encountered error during from-scratch indexing of ${current.realmURL.href}`,
        e,
      );
    }
    return {
      invalidations: [...(invalidations ?? [])].map((url) => url.href),
      ignoreData: current.#ignoreData,
      stats: current.stats,
    };
  }

  static async incremental(
    current: CurrentRun,
    {
      url,
      operation,
    }: {
      url: URL;
      operation: 'update' | 'delete';
    },
  ): Promise<IndexResults> {
    let start = Date.now();
    log.debug(`starting from incremental indexing for ${url.href}`);
    let invalidations: URL[] = [];
    try {
      current.#batch = await current.#indexWriter.createBatch(current.realmURL);
      invalidations = (await current.batch.invalidate(url)).map(
        (href) => new URL(href),
      );

      await current.whileIndexing(async () => {
        for (let invalidation of invalidations) {
          if (operation === 'delete' && invalidation.href === url.href) {
            // file is deleted, there is nothing to visit
          } else {
            await current.tryToVisit(invalidation);
          }
        }

        let { totalIndexEntries } = await current.batch.done();
        current.stats.totalIndexEntries = totalIndexEntries;

        log.debug(
          `completed incremental indexing for ${url.href} in ${
            Date.now() - start
          }ms`,
        );
      });
    } catch (e: any) {
      console.error(
        `Encountered error during incremental indexing of ${url.href}`,
        e,
      );
    }
    return {
      invalidations: [...invalidations].map((url) => url.href),
      ignoreData: current.#ignoreData,
      stats: current.stats,
    };
  }

  private async tryToVisit(url: URL) {
    try {
      await this.visitFile(url);
    } catch (err: any) {
      if (isCardError(err) && err.status === 404) {
        log.info(`tried to visit file ${url.href}, but it no longer exists`);
      } else {
        throw err;
      }
    }
  }

  private async whileIndexing(doIndexing: () => Promise<void>) {
    this.loaderService.setIsIndexing(true);
    await doIndexing();
    this.loaderService.setIsIndexing(false);
  }

  private get batch() {
    if (!this.#batch) {
      throw new Error('Batch is missing');
    }
    return this.#batch;
  }

  get ignoreData() {
    return this.#ignoreData;
  }

  get realmURL() {
    return this.#realmURL;
  }

  @cached
  private get ignoreMap() {
    let ignoreMap = new Map<string, Ignore>();
    for (let [url, contents] of Object.entries(this.#ignoreData)) {
      ignoreMap.set(url, ignore().add(contents));
    }
    return ignoreMap;
  }

  private async discoverInvalidations(
    url: URL,
    indexMtimes: LastModifiedTimes,
  ): Promise<string[]> {
    log.debug(`discovering invalidations in dir ${url.href}`);
    perfLog.debug(`discovering invalidations in dir ${url.href}`);
    let ignoreStart = Date.now();
    let ignorePatterns = await this.#reader.readFile(
      new URL('.gitignore', url),
    );
    perfLog.debug(`time to get ignore rules ${Date.now() - ignoreStart} ms`);
    if (ignorePatterns && ignorePatterns.content) {
      this.ignoreMap.set(url.href, ignore().add(ignorePatterns.content));
      this.#ignoreData[url.href] = ignorePatterns.content;
    }

    let mtimesStart = Date.now();
    let filesystemMtimes = await this.#reader.mtimes();
    perfLog.debug(
      `time to get file system mtimes ${Date.now() - mtimesStart} ms`,
    );
    let invalidationList: string[] = [];
    let skipList: string[] = [];
    for (let [url, lastModified] of Object.entries(filesystemMtimes)) {
      if (!url.endsWith('.json') && !hasExecutableExtension(url)) {
        // Only allow json and executable files to be invalidated so that we
        // don't end up with invalidated files that weren't meant to be indexed
        // (images, etc)
        continue;
      }
      let indexEntry = indexMtimes.get(url);

      if (
        !indexEntry ||
        indexEntry.type === 'error' ||
        indexEntry.lastModified == null ||
        lastModified !== indexEntry.lastModified
      ) {
        invalidationList.push(url);
      } else {
        skipList.push(url);
      }
    }
    if (skipList.length === 0) {
      // the whole realm needs to be visited, no need to calculate
      // invalidations--it's everything
      return invalidationList;
    }

    let invalidationStart = Date.now();
    for (let invalidationURL of invalidationList) {
      await this.batch.invalidate(new URL(invalidationURL));
    }
    perfLog.debug(
      `time to invalidate ${url} ${Date.now() - invalidationStart} ms`,
    );
    return this.batch.invalidations;
  }

  private async visitFile(
    url: URL,
    identityContext?: IdentityContextWithErrors,
  ): Promise<void> {
    if (isIgnored(this.#realmURL, this.ignoreMap, url)) {
      return;
    }
    let start = Date.now();
    log.debug(`begin visiting file ${url.href}`);
    let localPath: string;
    try {
      localPath = this.#realmPaths.local(url);
    } catch (e) {
      // until we have cross realm invalidation, if our invalidation
      // graph cross a realm just skip over the file. it will be out
      // of date, but such is life...
      log.debug(
        `Visit of ${url.href} cannot be performed as it is in a different realm than the realm whose contents are being invalidated (${this.realmURL.href})`,
      );
      return;
    }

    let fileRef = await this.#reader.readFile(url);
    if (!fileRef) {
      fileRef = await this.#reader.readFile(new URL(encodeURI(localPath), url));
    }
    if (!fileRef) {
      let error = new CardError(`missing file ${url.href}`, { status: 404 });
      error.deps = [url.href];
      throw error;
    }
    let { content, lastModified, created } = fileRef;
    if (hasExecutableExtension(url.href)) {
      await this.indexModule(url, fileRef);
    } else {
      if (!identityContext) {
        identityContext = new IdentityContextWithErrors();
      }

      if (url.href.endsWith('.json')) {
        let resource;

        try {
          let { data } = JSON.parse(content);
          resource = data;
        } catch (e) {
          log.warn(`unable to parse ${url.href} as card JSON`);
        }

        if (resource && isCardResource(resource)) {
          if (lastModified == null) {
            log.warn(
              `No lastModified date available for ${url.href}, using current time`,
            );
            lastModified = unixTime(Date.now());
          }
          await this.indexCard({
            path: localPath,
            source: content,
            lastModified,
            resourceCreatedAt: created,
            resource,
            identityContext,
          });
        }
      }
    }
    log.debug(`completed visiting file ${url.href} in ${Date.now() - start}ms`);
  }

  private async indexModule(url: URL, ref: TextFileRef): Promise<void> {
    let module: Record<string, unknown>;
    try {
      module = await this.loaderService.loader.import(url.href);
    } catch (err: any) {
      this.stats.moduleErrors++;
      log.warn(
        `encountered error loading module "${url.href}": ${err.message}`,
      );
      let deps = await (
        await this.loaderService.loader.getConsumedModules(url.href)
      ).filter((u) => u !== url.href);
      await this.batch.updateEntry(url, {
        type: 'error',
        error: {
          status: 500,
          message: `encountered error loading module "${url.href}": ${err.message}`,
          additionalErrors: null,
          deps,
        },
      });
      return;
    }

    if (module) {
      for (let exportName of Object.keys(module)) {
        module[exportName]; // we do this so that we can allow code ref identifies to be wired up in the loader
      }
    }
    if (ref.isShimmed) {
      log.debug(`skipping indexing of shimmed module ${url.href}`);
      return;
    }
    let consumes = (
      await this.loaderService.loader.getConsumedModules(url.href)
    ).filter((u) => u !== url.href);
    let deps = consumes.map((d) => trimExecutableExtension(new URL(d)).href);
    await this.batch.updateEntry(url, {
      type: 'module',
      source: ref.content,
      lastModified: ref.lastModified,
      resourceCreatedAt: ref.created,
      deps: new Set(deps),
    });
    this.stats.modulesIndexed++;
  }

  private async indexCard({
    path,
    source,
    lastModified,
    resourceCreatedAt,
    resource,
    identityContext,
  }: {
    path: LocalPath;
    source: string;
    lastModified: number;
    resourceCreatedAt: number;
    resource: LooseCardResource;
    identityContext: IdentityContextWithErrors;
  }): Promise<void> {
    let fileURL = this.#realmPaths.fileURL(path).href;
    let indexingInstance = this.#indexingInstances.get(fileURL);
    if (indexingInstance) {
      return await indexingInstance;
    }
    let deferred = new Deferred<void>();
    this.#indexingInstances.set(fileURL, deferred.promise);
    let instanceURL = new URL(
      this.#realmPaths.fileURL(path).href.replace(/\.json$/, ''),
    );
    let moduleURL = new URL(
      moduleFrom(resource.meta.adoptsFrom),
      new URL(path, this.#realmURL),
    ).href;
    let typesMaybeError: TypesWithErrors | undefined;
    let uncaughtError: Error | undefined;
    let doc: SingleCardDocument | undefined;
    let searchData: Record<string, any> | undefined;
    let cardType: typeof CardDef | undefined;
    let isolatedHtml: string | undefined;
    let atomHtml: string | undefined;
    let iconHTML: string | undefined;
    let card: CardDef | undefined;
    let embeddedHtml: Record<string, string> | undefined;
    let fittedHtml: Record<string, string> | undefined;
    try {
      let api = await this.loaderService.loader.import<typeof CardAPI>(
        `${baseRealm.url}card-api`,
      );

      if (!this.#realmInfo) {
        let realmInfoResponse = await this.network.authedFetch(
          `${this.realmURL}_info`,
          { headers: { Accept: SupportedMimeType.RealmInfo } },
        );
        this.#realmInfo = (await realmInfoResponse.json())?.data?.attributes;
      }

      let adjustedResource: CardResource = {
        ...resource,
        ...{ id: instanceURL.href, type: 'card' },
      };
      //Realm info may be used by a card to render field values.
      //Example: catalog-entry-card
      merge(adjustedResource, {
        meta: {
          lastModified,
          resourceCreatedAt,
          realmInfo: this.#realmInfo,
          realmURL: this.realmURL.href,
        },
      });
      card = await api.createFromSerialized<typeof CardDef>(
        adjustedResource,
        { data: adjustedResource },
        new URL(fileURL),
        {
          identityContext,
        },
      );
      isolatedHtml = unwrap(
        sanitizeHTML(
          await this.#renderCard({
            card,
            format: 'isolated',
            visit: this.visitFile.bind(this),
            identityContext,
            realmPath: this.#realmPaths,
          }),
        ),
      );
      atomHtml = unwrap(
        sanitizeHTML(
          await this.#renderCard({
            card,
            format: 'atom',
            visit: this.visitFile.bind(this),
            identityContext,
            realmPath: this.#realmPaths,
          }),
        ),
      );
      iconHTML = unwrap(sanitizeHTML(this.#render(cardTypeIcon(card))));
      cardType = Reflect.getPrototypeOf(card)?.constructor as typeof CardDef;
      let data = api.serializeCard(card, { includeComputeds: true });
      // prepare the document for index serialization
      Object.values(data.data.relationships ?? {}).forEach(
        (rel) => delete (rel as Relationship).data,
      );
      //Add again realm info and realm URL here
      //since we won't get it from serializeCard.
      doc = merge(data, {
        data: {
          id: instanceURL.href,
          meta: {
            lastModified,
            resourceCreatedAt,
            realmInfo: this.#realmInfo,
            realmURL: this.realmURL.href,
          },
        },
      }) as SingleCardDocument;
      searchData = await api.searchDoc(card);

      if (!searchData) {
        throw new Error(
          `bug: could not derive search doc for instance ${instanceURL.href}`,
        );
      }

      // Add a "pseudo field" to the search doc for the card type. We use the
      // "_" prefix to make a decent attempt to not pollute the userland
      // namespace for cards
      searchData._cardType = getDisplayName(cardType);
      typesMaybeError = await this.getTypes(cardType);
      if (card && typesMaybeError?.type === 'types') {
        embeddedHtml = await this.buildCardHtml(
          card,
          typesMaybeError.types,
          'embedded',
          identityContext,
        );
      }
      if (card && typesMaybeError?.type === 'types') {
        fittedHtml = await this.buildCardHtml(
          card,
          typesMaybeError.types,
          'fitted',
          identityContext,
        );
      }
    } catch (err: any) {
      uncaughtError = err;

      // even when there is an error, do our best to try loading card type
      // directly, this will help better populate the index card with error
      // instances when there is no last known good state
      if (!typesMaybeError) {
        try {
          let cardType = (await loadCard(resource.meta.adoptsFrom, {
            loader: this.loaderService.loader,
            relativeTo: instanceURL,
          })) as typeof CardDef;
          typesMaybeError = await this.getTypes(cardType);
          searchData = searchData ?? {};
          searchData._cardType = getDisplayName(cardType);
        } catch (cardTypeErr: any) {
          // the enclosing exception above should have captured this error already
        }
      }
    }

    if (searchData && doc && typesMaybeError?.type === 'types') {
      await this.updateEntry(instanceURL, {
        type: 'instance',
        source,
        resource: doc.data,
        searchData,
        isolatedHtml,
        atomHtml,
        embeddedHtml,
        fittedHtml,
        iconHTML,
        lastModified,
        resourceCreatedAt,
        types: typesMaybeError.types.map(({ refURL }) => refURL),
        displayNames: typesMaybeError.types.map(
          ({ displayName }) => displayName,
        ),
        deps: new Set([
          moduleURL,
          ...(await this.loaderService.loader.getConsumedModules(moduleURL)),
        ]),
      });
    } else if (uncaughtError || typesMaybeError?.type === 'error') {
      let error: ErrorEntry;
      identityContext.errors.add(instanceURL.href);
      if (uncaughtError) {
        error = {
          type: 'error',
          searchData,
          types:
            typesMaybeError?.type != 'error'
              ? typesMaybeError?.types.map(({ refURL }) => refURL)
              : undefined,
          error:
            uncaughtError instanceof CardError
              ? serializableError(uncaughtError)
              : { message: `${uncaughtError.message}` },
        };
        error.error.deps = [
          moduleURL,
          ...(uncaughtError instanceof CardError
            ? uncaughtError.deps ?? []
            : []),
        ];
      } else if (typesMaybeError?.type === 'error') {
        error = { type: 'error', error: typesMaybeError.error };
      } else {
        let err = new Error(`bug: should never get here`);
        deferred.reject(err);
        throw err;
      }
      log.warn(
        `encountered error indexing card instance ${path}: ${error.error.message}`,
      );
      await this.updateEntry(instanceURL, error);
    }
    deferred.fulfill();
  }

  private async buildCardHtml(
    card: CardDef,
    types: CardType[],
    format: 'embedded' | 'fitted',
    identityContext: IdentityContextWithErrors,
  ): Promise<{ [refURL: string]: string }> {
    let result: { [refURL: string]: string } = {};
    for (let { codeRef: componentCodeRef, refURL } of types) {
      let html = unwrap(
        sanitizeHTML(
          await this.#renderCard({
            card,
            format,
            visit: this.visitFile.bind(this),
            identityContext,
            realmPath: this.#realmPaths,
            componentCodeRef,
          }),
        ),
      );
      result[refURL] = html;
    }
    return result;
  }

  private async updateEntry(
    instanceURL: URL,
    entry: InstanceEntry | ErrorEntry,
  ) {
    await this.batch.updateEntry(assertURLEndsWithJSON(instanceURL), entry);
    if (entry.type === 'instance') {
      this.stats.instancesIndexed++;
    } else {
      this.stats.instanceErrors++;
    }
  }

  private async getTypes(card: typeof CardDef): Promise<TypesWithErrors> {
    let cached = this.#typesCache.get(card);
    if (cached) {
      return await cached;
    }
    let ref = identifyCard(card);
    if (!ref) {
      throw new Error(`could not identify card ${card.name}`);
    }
    let deferred = new Deferred<TypesWithErrors>();
    this.#typesCache.set(card, deferred.promise);
    let types: CardType[] = [];
    let fullRef: CodeRef = ref;
    while (fullRef) {
      let loadedCard: typeof CardAPI.CardDef,
        loadedCardRef: CodeRef | undefined;
      try {
        let maybeCard = await loadCard(fullRef, {
          loader: this.loaderService.loader,
        });
        if (!isCardDef(maybeCard)) {
          throw new Error(
            `The definition at ${JSON.stringify(fullRef)} is not a CardDef`,
          );
        }
        loadedCard = maybeCard;
        loadedCardRef = identifyCard(loadedCard);
        if (!loadedCardRef) {
          throw new Error(`could not identify card ${loadedCard.name}`);
        }
      } catch (error) {
        return { type: 'error', error: serializableError(error) };
      }

      types.push({
        refURL: internalKeyFor(loadedCardRef, undefined),
        codeRef: loadedCardRef,
        displayName: getDisplayName(loadedCard),
      });
      if (!isEqual(loadedCardRef, baseCardRef)) {
        fullRef = {
          type: 'ancestorOf',
          card: loadedCardRef,
        };
      } else {
        break;
      }
    }
    let result: TypesWithErrors = { type: 'types', types };
    deferred.fulfill(result);
    return result;
  }
}

function sanitizeHTML(html: string): string {
  // currently this only involves removing auto-generated ember ID's
  return html.replace(/\s+id="ember[0-9]+"/g, '');
}

function assertURLEndsWithJSON(url: URL): URL {
  if (!url.href.endsWith('.json')) {
    return new URL(`${url}.json`);
  }
  return url;
}

// we unwrap the outer div (and cleanup empty html comments) as the
// outer div is actually the container that the card HTML is
// rendering into
function unwrap(html: string): string {
  return html
    .trim()
    .replace(/^<div ([^>]*>)/, '')
    .trim()
    .replace(/^<!---->/, '')
    .replace(/<\/div>$/, '')
    .trim();
}

function getDisplayName(card: typeof CardDef) {
  if (card.displayName === 'Card') {
    return card.name;
  } else {
    return card.displayName;
  }
}
