export default config;

/**
 * Type declarations for
 *    import config from 'my-app/config/environment'
 */
declare const config: {
  environment: string;
  modulePrefix: string;
  podModulePrefix: string;
  locationType: 'history' | 'hash' | 'none' | 'auto';
  rootURL: string;
  APP: Record<string, unknown>;
  matrixURL: string;
  matrixServerName: string;
  experimentalAIEnabled: boolean;
  hostsOwnAssets: boolean;
  realmsServed?: string[];
  logLevels: string;
  autoSaveDelayMs: number;
  monacoDebounceMs: number;
  monacoCursorDebounceMs: number;
  serverEchoDebounceMs: number;
  loginMessageTimeoutMs: number;
  minSaveTaskDurationMs: number;
  sqlSchema: string;
  assetsURL: string;
  featureFlags?: {};
  exportApplicationGlobal: boolean;
};
