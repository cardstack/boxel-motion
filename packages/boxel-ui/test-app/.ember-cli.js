/* eslint-disable */
'use strict';

process.env.EMBER_VERSION = 'OCTANE';

const { setEdition } = require('@ember/edition-utils');

setEdition('octane');

module.exports = {
  /**
    Ember CLI sends analytics information by default. The data is completely
    anonymous, but there are times when you might want to disable this behavior.

    Setting `disableAnalytics` to true will prevent any data from being sent.
  */
  port: 4220,
  testPort: 7356,
  disableAnalytics: false,
};
