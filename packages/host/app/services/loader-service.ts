import Service, { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

import {
  VirtualNetwork,
  baseRealm,
  addAuthorizationHeader,
  IRealmAuthDataSource,
  fetcher,
} from '@cardstack/runtime-common';
import { Loader } from '@cardstack/runtime-common/loader';

import config from '@cardstack/host/config/environment';
import {
  type RealmSessionResource,
  getRealmSession,
} from '@cardstack/host/resources/realm-session';
import MatrixService from '@cardstack/host/services/matrix-service';
import RealmInfoService from '@cardstack/host/services/realm-info-service';

import { shimExternals } from '../lib/externals';

export default class LoaderService extends Service {
  @service declare fastboot: { isFastBoot: boolean };
  @service private declare matrixService: MatrixService;
  @service declare realmInfoService: RealmInfoService;

  @tracked loader = this.makeInstance();
  // This resources all have the same owner, it's safe to reuse cache.
  // The owner is the service, which stays around for the whole lifetime of the host app,
  // which in turn assures the resources will not get torn down.
  private realmSessions: Map<string, RealmSessionResource> = new Map();

  virtualNetwork = new VirtualNetwork();

  reset() {
    if (this.loader) {
      this.loader = Loader.cloneLoader(this.loader);
    } else {
      this.loader = this.makeInstance();
    }
  }

  private makeInstance() {
    if (this.fastboot.isFastBoot) {
      let loader = this.virtualNetwork.createLoader();
      shimExternals(this.virtualNetwork);
      return loader;
    }
    let { realmInfoService, getRealmSession } = this;
    let fetch = fetcher(this.virtualNetwork.fetch, [
      async (req, next) => {
        let handleAuth = addAuthorizationHeader(loader.fetch, {
          realmURL: undefined,
          getJWT: async (realmURL: string) => {
            return (await getRealmSession(new URL(realmURL))).rawRealmToken!;
          },
          getRealmInfo: async (url: string) => {
            let realmURL = await realmInfoService.fetchRealmURL(url);
            if (!realmURL) {
              return null;
            }
            let isPublicReadable = await realmInfoService.isPublicReadable(
              realmURL,
            );
            return {
              url: realmURL.href,
              isPublicReadable,
            };
          },
          resetAuth: async (realmURL: string) => {
            return (await getRealmSession(new URL(realmURL))).refreshToken();
          },
        } as IRealmAuthDataSource);
        let response = await handleAuth(req);
        return response || next();
      },
    ]);
    let loader = new Loader(fetch, this.virtualNetwork.resolveImport);
    this.virtualNetwork.addURLMapping(
      new URL(baseRealm.url),
      new URL(config.resolvedBaseRealmURL),
    );
    shimExternals(this.virtualNetwork);

    return loader;
  }

  private getRealmSession = async (realmURL: URL) => {
    let realmURLString = realmURL.href;
    let realmSession = this.realmSessions.get(realmURLString);

    if (!realmSession) {
      realmSession = getRealmSession(this, {
        realmURL: () => realmURL,
      });
      await realmSession.loaded;
      this.realmSessions.set(realmURLString, realmSession);
    }
    return realmSession;
  };
}
