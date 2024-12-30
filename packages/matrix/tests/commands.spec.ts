import { expect, test } from '@playwright/test';
import { Credentials, putEvent, registerUser } from '../docker/synapse';
import {
  APP_BOXEL_MESSAGE_MSGTYPE,
  APP_BOXEL_COMMAND_MSGTYPE,
  APP_BOXEL_COMMAND_RESULT_EVENT_TYPE,
  APP_BOXEL_COMMAND_RESULT_MSGTYPE,
} from '../helpers/matrix-constants';

import {
  login,
  getRoomId,
  sendMessage,
  registerRealmUsers,
  getRoomEvents,
  showAllCards,
  waitUntil,
  setupUserSubscribed,
} from '../helpers';
import {
  synapseStart,
  synapseStop,
  type SynapseInstance,
} from '../docker/synapse';
import {
  startServer as startRealmServer,
  type IsolatedRealmServer,
  appURL,
} from '../helpers/isolated-realm-server';

test.describe('Commands', () => {
  let synapse: SynapseInstance;
  let realmServer: IsolatedRealmServer;
  let userCred: Credentials;
  test.beforeEach(async () => {
    synapse = await synapseStart();
    realmServer = await startRealmServer();
    await registerRealmUsers(synapse);
    userCred = await registerUser(synapse, 'user1', 'pass');
    await setupUserSubscribed('@user1:localhost', realmServer);
  });
  test.afterEach(async () => {
    await synapseStop(synapse.synapseId);
    await realmServer.stop();
  });

  test(`it does include command tools (patch, search) in message event when top-most card is writable and context is shared`, async ({
    page,
  }) => {
    await login(page, 'user1', 'pass', { url: appURL });
    let room1 = await getRoomId(page);
    await showAllCards(page);
    await page
      .locator(
        `[data-test-stack-card="${appURL}/index"] [data-test-cards-grid-item="${appURL}/mango"]`,
      )
      .click();
    await expect(
      page.locator(`[data-test-stack-card="${appURL}/mango"]`),
    ).toHaveCount(1);
    await sendMessage(page, room1, 'please change this card');
    let message;
    await expect(async () => {
      message = (await getRoomEvents()).pop()!;
      expect(message?.content?.msgtype).toStrictEqual(
        APP_BOXEL_MESSAGE_MSGTYPE,
      );
    }).toPass();
    let boxelMessageData = JSON.parse(message!.content.data);

    expect(boxelMessageData.context.tools.length).toEqual(2);
    let patchCardTool = boxelMessageData.context.tools.find(
      (t: any) => t.function.name === 'patchCard',
    );
    expect(patchCardTool).toMatchObject({
      type: 'function',
      function: {
        name: 'patchCard',
        description:
          'Propose a patch to an existing card to change its contents. Any attributes specified will be fully replaced, return the minimum required to make the change. If a relationship field value is removed, set the self property of the specific item to null. When editing a relationship array, display the full array in the patch code. Ensure the description explains what change you are making.',
        parameters: {
          type: 'object',
          properties: {
            attributes: {
              type: 'object',
              properties: {
                cardId: {
                  type: 'string',
                  const: `${appURL}/mango`,
                },
                patch: {
                  type: 'object',
                  properties: {
                    attributes: {
                      type: 'object',
                      properties: {
                        firstName: {
                          type: 'string',
                        },
                        lastName: {
                          type: 'string',
                        },
                        email: {
                          type: 'string',
                        },
                        posts: {
                          type: 'number',
                        },
                        thumbnailURL: {
                          type: 'string',
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          required: ['attributes', 'description'],
        },
      },
    });
    let searchCardTool = boxelMessageData.context.tools.find(
      (t: any) => t.function.name === 'searchCard',
    );
    expect(searchCardTool).toMatchObject({
      type: 'function',
      function: {
        name: 'searchCard',
        description:
          'Propose a query to search for a card instance filtered by type.   If a card was shared with you, always prioritise search based upon the card that was last shared.   If you do not have information on card module and name, do the search using the `_cardType` attribute.',
        parameters: {
          type: 'object',
          properties: {
            description: {
              type: 'string',
            },
            attributes: {
              type: 'object',
              properties: {
                filter: {
                  type: 'object',
                  properties: {
                    contains: {
                      type: 'object',
                      properties: {
                        title: {
                          type: 'string',
                          description: 'title of the card',
                        },
                      },
                      required: ['title'],
                    },
                    eq: {
                      type: 'object',
                      properties: {
                        _cardType: {
                          type: 'string',
                          description: 'name of the card type',
                        },
                      },
                      required: ['_cardType'],
                    },
                  },
                },
              },
            },
          },
          required: ['attributes', 'description'],
        },
      },
    });
  });

  test(`it does not include patch tool in message event for an open card that is not attached`, async ({
    page,
  }) => {
    await login(page, 'user1', 'pass', { url: appURL });
    let room1 = await getRoomId(page);
    await showAllCards(page);
    await page
      .locator(
        `[data-test-stack-card="${appURL}/index"] [data-test-cards-grid-item="${appURL}/mango"]`,
      )
      .click();
    await expect(
      page.locator(`[data-test-stack-card="${appURL}/mango"]`),
    ).toHaveCount(1);
    await page
      .locator(
        `[data-test-attached-card="${appURL}/mango"] [data-test-remove-card-btn]`,
      )
      .click();
    await sendMessage(page, room1, 'please change this card');
    let message;
    await expect(async () => {
      message = (await getRoomEvents()).pop()!;
      expect(message?.content?.msgtype).toStrictEqual(
        APP_BOXEL_MESSAGE_MSGTYPE,
      );
    }).toPass();
    let boxelMessageData = JSON.parse(message!.content.data);
    expect(boxelMessageData.context.tools).toMatchObject([]);
  });

  // TODO: currently we need isolated realm server to get payment setup to work
  /*   test(`it does not include patch tool in message event when top-most card is read-only`, async ({
    page,
  }) => {
    // the base realm is a read-only realm
    await login(page, 'user1', 'pass', { url: `http://localhost:4201/base` });
    let room1 = await getRoomId(page);
    await showAllCards(page);
    await expect(
      page.locator(
        '[data-test-stack-card="https://cardstack.com/base/index"] [data-test-cards-grid-item="https://cardstack.com/base/fields/boolean-field"]',
      ),
    ).toHaveCount(1);
    await page
      .locator(
        '[data-test-stack-card="https://cardstack.com/base/index"] [data-test-cards-grid-item="https://cardstack.com/base/fields/boolean-field"]',
      )
      .click();
    await expect(
      page.locator(
        '[data-test-stack-card="https://cardstack.com/base/fields/boolean-field"]',
      ),
    ).toHaveCount(1);
    await sendMessage(page, room1, 'please change this card');
    let message = (await getRoomEvents()).pop()!;
    expect(message.content.msgtype).toStrictEqual(APP_BOXEL_MESSAGE_MSGTYPE);
    let boxelMessageData = JSON.parse(message.content.data);
    expect(boxelMessageData.context.tools).toMatchObject([]);
  }); */

  test(`applying a command dispatches a CommandResultEvent if command is succesful`, async ({
    page,
  }) => {
    await login(page, 'user1', 'pass', { url: appURL });
    let room1 = await getRoomId(page);
    let cardId = `${appURL}/hassan`;
    let content = {
      msgtype: APP_BOXEL_COMMAND_MSGTYPE,
      format: 'org.matrix.custom.html',
      body: 'some command',
      formatted_body: 'some command',
      data: JSON.stringify({
        toolCall: {
          name: 'patchCard',
          arguments: {
            description: 'Patching card',
            attributes: {
              cardId,
              patch: {
                attributes: {
                  firstName: 'Dave',
                },
              },
            },
          },
        },
      }),
    };

    await showAllCards(page);
    await page
      .locator(
        `[data-test-stack-card="${appURL}/index"] [data-test-cards-grid-item="${cardId}"]`,
      )
      .click();
    await putEvent(userCred.accessToken, room1, 'm.room.message', '1', content);
    await page.locator('[data-test-command-apply]').click();
    await page.locator('[data-test-command-idle]');

    await expect(async () => {
      let events = await getRoomEvents('user1', 'pass', room1);
      let commandResultEvent = (events as any).find(
        (e: any) => e.type === APP_BOXEL_COMMAND_RESULT_EVENT_TYPE,
      );
      await expect(commandResultEvent).toBeDefined();
    }).toPass();
  });

  test(`applying a search command dispatches a result event if command is succesful and result is returned`, async ({
    page,
  }) => {
    await login(page, 'user1', 'pass', { url: appURL });
    let room1 = await getRoomId(page);
    let card_id = `${appURL}/hassan`;
    let content = {
      msgtype: APP_BOXEL_COMMAND_MSGTYPE,
      format: 'org.matrix.custom.html',
      body: 'some command',
      formatted_body: 'some command',
      data: JSON.stringify({
        toolCall: {
          name: 'searchCard',
          arguments: {
            attributes: {
              description: 'Searching for card',
              filter: {
                type: {
                  module: `${appURL}person`,
                  name: 'Person',
                },
              },
            },
          },
        },
        eventId: 'search1',
      }),
    };

    await showAllCards(page);
    await page
      .locator(
        `[data-test-stack-card="${appURL}/index"] [data-test-cards-grid-item="${card_id}"]`,
      )
      .click();
    await putEvent(userCred.accessToken, room1, 'm.room.message', '1', content);
    await page.locator('[data-test-command-apply]').click();
    await page.locator('[data-test-command-idle]');
    await expect(async () => {
      let events = await getRoomEvents('user1', 'pass', room1);
      let commandResultEvent = (events as any).find(
        (e: any) => e.content.msgtype === APP_BOXEL_COMMAND_RESULT_MSGTYPE,
      );
      await expect(commandResultEvent).toBeDefined();
      await expect(commandResultEvent.content.data.cardEventId).toBeDefined();
    }).toPass();
  });

  test('a command sent via SendAiAssistantMessageCommand becomes an available tool', async ({
    page,
  }) => {
    await login(page, 'user1', 'pass', { url: appURL });
    await showAllCards(page);
    await page
      .locator(
        `[data-test-stack-card="${appURL}/index"] [data-test-cards-grid-item="${appURL}/mango"]`,
      )
      .click();
    await expect(
      page.locator(`[data-test-stack-card="${appURL}/mango"]`),
    ).toHaveCount(1);
    await page.locator('[data-test-switch-to-code-mode-button]').click();
    await waitUntil(async () => (await getRoomEvents()).length > 0);
    let message = (await getRoomEvents()).pop()!;
    expect(message.content.msgtype).toStrictEqual(APP_BOXEL_MESSAGE_MSGTYPE);
    let boxelMessageData = JSON.parse(message.content.data);
    expect(boxelMessageData.context.tools.length).toEqual(1);
    expect(boxelMessageData.context.tools[0].type).toEqual('function');
    expect(boxelMessageData.context.tools[0].function.name).toMatch(
      /^SwitchSubmodeCommand_/,
    );
    expect(boxelMessageData.context.tools[0].function.description).toEqual(
      'Navigate the UI to another submode. Possible values for submode are "interact" and "code".',
    );
    // TODO: do we need to include `required: ['attributes'],` in the parameters object? If so, how?
    expect(boxelMessageData.context.tools[0].function.parameters).toMatchObject(
      {
        type: 'object',
        properties: {
          attributes: {
            type: 'object',
            properties: {
              submode: {
                type: 'string',
              },
              title: {
                type: 'string',
              },
              description: {
                type: 'string',
              },
              thumbnailURL: {
                type: 'string',
              },
            },
          },
        },
      },
    );
  });
});
