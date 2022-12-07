export const boxelCssVariables = `
    --boxel-font-family: "Open Sans", helvetica, arial, sans-serif;
    --boxel-monospace-font-family: "Roboto Mono", "Courier New", courier, monospace;
    --boxel-font-xl: var(--boxel-font-size-xl)/calc(43 / 32) var(--boxel-font-family);
    --boxel-font-lg: var(--boxel-font-size-lg)/calc(30 / 22) var(--boxel-font-family);
    --boxel-font: var(--boxel-font-size)/calc(22 / 16) var(--boxel-font-family);        /* default */
    --boxel-font-sm: var(--boxel-font-size-sm)/calc(18 / 13) var(--boxel-font-family);
    --boxel-font-xs: var(--boxel-font-size-xs)/calc(15 / 11) var(--boxel-font-family);

    /* font-sizes */
    --boxel-font-size-xl: 2rem;
    --boxel-font-size-lg: 1.375rem;
    --boxel-font-size: 1rem;      /* default - 16px */
    --boxel-font-size-sm: 0.8125rem;
    --boxel-font-size-xs: 0.6875rem;

    /* letter-spacing */
    --boxel-lsp-xxl: 0.1em;
    --boxel-lsp-xl: 0.05em;
    --boxel-lsp-lg: 0.035em;
    --boxel-lsp: 0.025em;
    --boxel-lsp-sm: 0.015em;
    --boxel-lsp-xs: 0.01em;
    --boxel-lsp-xxs: 0.005em;

    /* Modular scale for spacing */
    --boxel-spacing: 1.25rem; /* base size (20px) */
    --boxel-ratio: 1.333;     /* scale (based on "Perfect Fourth" scale) */
    --boxel-sp-xxxs: calc(var(--boxel-sp-xxs) / var(--boxel-ratio)); /* 6.33px */
    --boxel-sp-xxs: calc(var(--boxel-sp-xs) / var(--boxel-ratio));   /* 8.44px */
    --boxel-sp-xs: calc(var(--boxel-sp-sm) / var(--boxel-ratio));    /* 11.26px */
    --boxel-sp-sm: calc(var(--boxel-sp) / var(--boxel-ratio));       /* 15px */
    --boxel-sp: var(--boxel-spacing);                                /* 20px */
    --boxel-sp-lg: calc(var(--boxel-sp) * var(--boxel-ratio));       /* 26.66px */
    --boxel-sp-xl: calc(var(--boxel-sp-lg) * var(--boxel-ratio));    /* 35.54px */
    --boxel-sp-xxl: calc(var(--boxel-sp-xl) * var(--boxel-ratio));   /* 47.37px */
    --boxel-sp-xxxl: calc(var(--boxel-sp-xxl) * var(--boxel-ratio)); /* 63.15px */

    /* common icon sizes */
    --boxel-icon-sm: 1.25rem; /* 20px */
    --boxel-icon-lg: 2.5rem;  /* 40px */
    --boxel-icon-xl: 3.75rem; /* 60px */
    --boxel-icon-xxl: 5rem;   /* 80px */

    /* other */
    --boxel-border-color: var(--boxel-light-500);
    --boxel-border: 1px solid var(--boxel-border-color);
    --boxel-border-dark: 1px solid var(--boxel-dark);
    --boxel-border-radius-xs: 2px;
    --boxel-border-radius-sm: 5px;
    --boxel-border-radius: 10px;
    --boxel-border-radius-lg: 15px;
    --boxel-transition: 0.2s ease;
    --boxel-box-shadow: 0 1px 3px rgb(0 0 0 / 25%);
    --boxel-box-shadow-hover: 0 3px 10px rgb(0 0 0 / 15%);
    --boxel-outline-color: var(--boxel-blue);
    --boxel-outline: 2px solid var(--boxel-outline-color);

    /* Container sizes */
    --boxel-xxs-container: 15.625rem; /* 250px */
    --boxel-xs-container: 17.8125rem; /* 285px */
    --boxel-sm-container: 36.25rem;   /* 580px */
    --boxel-md-container: 40.625rem;  /* 650px */
    --boxel-lg-container: 43.75rem;   /* 700px */
    --boxel-xl-container: 65rem;      /* 1040px */
    --boxel-xxl-container: 83.76rem;  /* 1340px */

    /* COLOR PALETTE */

    /* Primary colors */
    --boxel-light: #fff;
    --boxel-dark: #000;

    /*
      --boxel-highlight (#00ebe5) use cases:
      on dark background: text links, icons, CTA buttons
      on light background: CTA buttons, graph line

      --boxel-dark-highlight (#03c4bf) use cases:
      on light background: copy, text links, icons only

      --boxel-link-highlight:
      it is set to var(--boxel-dark-highlight) by default - since default background is light
      it is the color for a:hover
      set it to var(--boxel-highlight) on dark backgrounds
    */
    --boxel-highlight: var(--boxel-cyan);
    --boxel-highlight-hover: #00d3ce;
    --boxel-dark-highlight: var(--boxel-teal);
    --boxel-link-highlight: var(--boxel-dark-highlight);
    --boxel-danger: #ff4852;
    --boxel-danger-hover: #fa1521;

    /* Boxel purples */
    --boxel-purple-100: #f8f7fa;
    --boxel-purple-200: #b3b1b8;
    --boxel-purple-300: #afafb7;
    --boxel-purple-400: #6b6a80;
    --boxel-purple-500: #5a586a;
    --boxel-purple-600: #413e4e;
    --boxel-purple-700: #393642;
    --boxel-purple-750: #363441;
    --boxel-purple-800: #2e2d38;
    --boxel-purple-900: #272330;

    /* Boxel neutrals */
    --boxel-light-100: #f5f5f5;
    --boxel-light-200: #f0f0f0;
    --boxel-light-300: #efefef;
    --boxel-light-400: #e8e8e8;
    --boxel-light-500: #dedede;
    --boxel-light-600: #d1d1d1;

    /* Boxel colors */
    --boxel-navy: #281e78;
    --boxel-blue: #0069f9;
    --boxel-purple: #6638ff;
    --boxel-fuschia: #ac00ff;
    --boxel-lilac: #a66dfa;
    --boxel-cyan: #00ebe5;
    --boxel-teal: #03c4bf;
    --boxel-green: #37eb77;
    --boxel-dark-green: #00ac3d;
    --boxel-lime: #c3fc33;
    --boxel-yellow: #ffd800;
    --boxel-orange: #ff7f00;
    --boxel-red: #ff5050;
    --boxel-pink: #ff009d;

    /* Status colors */
    --boxel-error-100: #f00;    /* alert - attention - error */
    --boxel-error-200: #ed0000;
    --boxel-warning-100: var(--boxel-yellow); /* warning - notification */
    --boxel-success-100: var(--boxel-green);
    --boxel-success-200: var(--boxel-teal);
    --boxel-success-300: var(--boxel-dark-green);

    /* z-index layers */
    --boxel-layer-modal-default: 15;
    --boxel-layer-modal-urgent: 20;

    /* Form control appearance */
    --boxel-form-control-height: 2.5rem;  /* 40px */
    --boxel-form-control-placeholder-color: var(--boxel-purple-400);
    --boxel-form-control-border-color: var(--boxel-purple-300);
    --boxel-form-control-border-radius: var(--boxel-border-radius-sm);
`;
