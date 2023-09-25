import Application from '@ember/application';
import Resolver from 'ember-resolver';
import loadInitializers from 'ember-load-initializers';
import config from 'test-app/config/environment';
import '@cardstack/boxel-ui/styles/global.css';
import '@cardstack/boxel-ui/styles/fonts.css';
import '@cardstack/boxel-ui/styles/variables.css';

export default class App extends Application {
  modulePrefix = config.modulePrefix;
  podModulePrefix = config.podModulePrefix;
  Resolver = Resolver;
}

loadInitializers(App, config.modulePrefix);
