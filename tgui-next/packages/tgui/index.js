import 'core-js/stable';
import 'regenerator-runtime/runtime';
import './polyfills';

import { loadCSS } from 'fg-loadcss';
import { render } from 'inferno';
import { setupHotReloading } from 'tgui-dev-server/link/client';
import { backendUpdate } from './backend';
import { act, tridentVersion } from './byond';
import { setupDrag } from './drag';
import { createLogger, setLoggerRef } from './logging';
import { getRoute } from './routes';
import { createStore } from './store';

const logger = createLogger();
const store = createStore();
const reactRoot = document.getElementById('react-root');

let initialRender = true;
let handedOverToOldTgui = false;

const renderLayout = () => {
  // Short-circuit the renderer
  if (handedOverToOldTgui) {
    return;
  }
  try {
    const state = store.getState();
    // Initial render setup
    if (initialRender) {
      initialRender = false;

      logger.log('initial render', state);
      // Setup dragging
      setupDrag(state);
    }
    // Start rendering
    const { Layout } = require('./layout');
    const element = <Layout state={state} dispatch={store.dispatch} />;
    render(element, reactRoot);
  }
  catch (err) {
    logger.error('rendering error', err.stack || String(err));
  }
};

const setupApp = () => {
  // Find data in the page, load inlined state.
  const holder = document.getElementById('data');
  const ref = holder.getAttribute('data-ref');

  // Initialize logger
  setLoggerRef(ref);

  // Subscribe for state updates
  store.subscribe(() => {
    renderLayout();
  });

  // Subscribe for bankend updates
  window.update = window.initialize = stateJson => {
    const state = JSON.parse(stateJson);
    // Backend update dispatches a store action
    store.dispatch(backendUpdate(state));
  };

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept(['./layout', './routes'], () => {
      renderLayout();
    });
  }

  // Initialize
  act(ref, 'tgui:initialize');

  // Dynamically load font-awesome from browser's cache
  loadCSS('font-awesome.css');
};

// Wait for DOM to properly load on IE8
if (tridentVersion <= 4) {
  if (document.readyState !== 'loading') {
    setupApp();
  }
  else {
    document.addEventListener('DOMContentLoaded', setupApp);
  }
}
// Load right away on all other browsers
else {
  setupApp();
}
