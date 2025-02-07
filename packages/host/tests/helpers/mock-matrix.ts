import Owner from '@ember/owner';

import window from 'ember-window-mock';

import type MatrixService from '@cardstack/host/services/matrix-service';

import { MockSDK } from './mock-matrix/_sdk';
import { MockUtils } from './mock-matrix/_utils';

export interface Config {
  loggedInAs?: string;
  displayName?: string;
  activeRealms?: string[];
  realmPermissions?: Record<string, string[]>;
  expiresInSec?: number;
  autostart?: boolean;
  now?: () => number;
}

export function setupMockMatrix(
  hooks: NestedHooks,
  opts: Config = {},
): MockUtils {
  let testState: { owner?: Owner; sdk?: MockSDK; opts?: Config } = {
    owner: undefined,
    sdk: undefined,
    opts: undefined,
  };

  let mockUtils = new MockUtils(testState);

  hooks.beforeEach(async function () {
    testState.owner = this.owner;
    testState.opts = { ...opts };
    let sdk = new MockSDK(testState.opts);
    testState.sdk = sdk;
    const { loggedInAs } = opts;
    if (loggedInAs) {
      window.localStorage.setItem(
        'auth',
        JSON.stringify({
          access_token: 'mock-access-token',
          device_id: 'mock-device-id',
          user_id: loggedInAs,
        }),
      );
    }
    this.owner.register(
      'service:matrixSdkLoader',
      {
        async load() {
          return sdk;
        },
      },
      {
        instantiate: false,
      },
    );
    this.owner.register(
      'service:matrix-mock-utils',
      {
        async load() {
          return mockUtils;
        },
      },
      {
        instantiate: false,
      },
    );
    if (opts.autostart) {
      let matrixService = this.owner.lookup(
        'service:matrix-service',
      ) as MatrixService;
      await matrixService.ready;
      await matrixService.start();
    }
  });
  return mockUtils;
}
