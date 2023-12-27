import { fn } from '@ember/helper';
import { service } from '@ember/service';
import Component from '@glimmer/component';

import { CardContainer, BoxelHeader } from '@cardstack/boxel-ui/components';
import { eq } from '@cardstack/boxel-ui/helpers';
import { BoxelIcon } from '@cardstack/boxel-ui/icons';

import type MatrixService from '@cardstack/host/services/matrix-service';

import ForgotPassword from './forgot-password';
import Login from './login';
import RegisterUser from './register-user';

export default class Auth extends Component {
  <template>
    <div class='auth'>
      <div class='container'>
        <CardContainer class='form'>
          <BoxelHeader @title='Boxel' @hasBackground={{false}} class='header'>
            <:icon>
              <BoxelIcon />
            </:icon>
          </BoxelHeader>
          <div class='content'>
            {{#if (eq this.mode 'register')}}
              <RegisterUser
                @onCancel={{fn this.matrixService.setAuthMode 'login'}}
              />
            {{else if (eq this.mode 'forgot-password')}}
              <ForgotPassword
                @onLogin={{fn this.matrixService.setAuthMode 'login'}}
              />
            {{else}}
              <Login
                @onRegistration={{fn this.matrixService.setAuthMode 'register'}}
                @onForgotPassword={{fn
                  this.matrixService.setAuthMode
                  'forgot-password'
                }}
              />
            {{/if}}
          </div>
        </CardContainer>
      </div>
    </div>

    <style>
      .auth {
        height: 100%;
        overflow: auto;
      }

      .container {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        min-height: 100%;
        padding: var(--boxel-sp-lg);
      }

      .form {
        background-color: var(--boxel-light);
        border: 1px solid var(--boxel-form-control-border-color);
        border-radius: var(--boxel-form-control-border-radius);
        letter-spacing: var(--boxel-lsp);
        width: 550px;
        position: relative;
      }
      .header {
        --boxel-header-icon-width: var(--boxel-icon-med);
        --boxel-header-icon-height: var(--boxel-icon-med);
        --boxel-header-padding: var(--boxel-sp);
        --boxel-header-text-size: var(--boxel-font);

        background-color: var(--boxel-light);
        text-transform: uppercase;
        max-width: max-content;
        min-width: 100%;
        gap: var(--boxel-sp-xxs);
        letter-spacing: var(--boxel-lsp-lg);
      }
      .content {
        display: flex;
        flex-direction: column;
        padding: var(--boxel-sp) var(--boxel-sp-xl) calc(var(--boxel-sp) * 2)
          var(--boxel-sp-xl);
      }
    </style>
  </template>

  @service private declare matrixService: MatrixService;

  private get mode() {
    return this.matrixService.authState.mode;
  }
}

declare module '@glint/environment-ember-loose/registry' {
  export default interface Login {
    'Matrix::Login': typeof Login;
  }
}
