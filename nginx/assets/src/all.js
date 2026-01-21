import { nodeListForEach } from './lib/nodeListForEach.js';
import Actions from './action.js'

function initAll() {
    const $actions = document.querySelectorAll('[data-module="app-actions"]');
    nodeListForEach($actions, ($el) => {
        new Actions($el).init();
    })
}

export { initAll, Actions }
