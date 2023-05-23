import './e2ee';
import { Deferred } from '@cardstack/runtime-common';
import { type MatrixClient, createClient } from 'matrix-js-sdk';

interface Params {
  matrixServerURL: string;
  accessToken: string;
  userId: string;
  deviceId: string;
  deferStartUp?: true;
}

// For now the only kind of append only realm is a matrix realm so this class
// will directly consume matrix SDK for the time being
export class MatrixRealm {
  #startedUp = new Deferred<void>();
  #deferStartup: boolean;
  #client: MatrixClient;
  #matrixServerURL: string;
  #accessToken: string;
  #deviceId: string;
  #userId: string;

  constructor({
    matrixServerURL,
    accessToken,
    userId,
    deviceId,
    deferStartUp,
  }: Params) {
    this.#matrixServerURL = matrixServerURL;
    this.#accessToken = accessToken;
    this.#deviceId = deviceId;
    this.#userId = userId;
    this.#client = createClient({ baseUrl: matrixServerURL });

    this.#deferStartup = deferStartUp ?? false;
    if (!deferStartUp) {
      this.#startedUp.fulfill((() => this.#startup())());
    }
  }

  get ready(): Promise<void> {
    return this.#startedUp.promise;
  }

  get #isLoggedIn() {
    return this.#client.isLoggedIn();
  }

  // it's only necessary to call this when the realm is using a deferred startup
  async start() {
    if (this.#deferStartup) {
      this.#startedUp.fulfill((() => this.#startup())());
    }
    await this.ready;
  }

  shutdown() {
    // note that it takes about 90 seconds to actually end the process after
    // shutdown() is called due to this bug in the matrix-js-sdk
    // https://github.com/matrix-org/matrix-js-sdk/issues/2472
    this.#client.stopClient();
  }

  async #startup() {
    await Promise.resolve();
    // await this.#warmUpCache();
    this.#client = createClient({
      baseUrl: this.#matrixServerURL,
      accessToken: this.#accessToken,
      userId: this.#userId,
      deviceId: this.#deviceId,
    });
    if (!this.#isLoggedIn) {
      throw new Error(
        `couldn't login to matrix server with provided credentials`
      );
    }

    try {
      await this.#client.initCrypto();
    } catch (e) {
      // when there are problems, these exceptions are hard to see so logging them explicitly
      console.error(`Error initializing crypto`, e);
      throw e;
    }

    // this let's us send messages to element clients (useful for testing).
    // probably we wanna verify these unknown devices (when in an encrypted
    // room). need to research how to do that as its undocumented API
    this.#client.setGlobalErrorOnUnknownDevices(false);
    await this.#client.startClient();

    // TODO need to handle token refresh as our session is very long-lived
  }

  // url: string;
  // searchIndex: SearchIndex;
  // ready: Promise<void>;
  // start(): Promise<void>;
  // write(path: LocalPath, contents: string): Promise<{ lastModified: number }>;
  // getIndexHTML(opts?: IndexHTMLOptions): Promise<string>;

  // note that append only does not support
  // delete()

  // common handler supports:
  // GET /_info
  // GET /_search
  // GET /_message
  // GET * accept: application/vnd.card+json
  // GET * accept: application/vnd.card+source
  // GET * accept: text/html
  // POST * accept: application/vnd.card+source
  // GET */ accept: application/vnd.json+api (directory listing)

  // note that append only does not support
  //  PATCH * accept: application/vnd.card+json
  //  DELETE * accept: application/vnd.card+json
  //  DELETE * accept: application/vnd.card+source
  // handle(request: MaybeLocalRequest): Promise<ResponseWithNodeStream>;
}
