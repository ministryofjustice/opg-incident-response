import { nodeListForEach } from 'govuk-frontend/govuk/common'
import api from './lib/api';

function Actions ($module) {
  this.$module = $module;
  this.incidentId = $module.getAttribute('data-incident-id');
  this.$actions = $module.querySelectorAll('input[type="checkbox"]');
}

Actions.prototype.init = function init() {
  nodeListForEach(this.$actions, $action => {
    $action.addEventListener('change', this.handleCheck.bind(this));
  });
}

Actions.prototype.handleCheck = function handleCheck(event) {
  const actionId = event.target.value;

  const form = new FormData();
  form.set('done', event.target.checked);
  form.set('done_date', event.target.checked ? (new Date()).toISOString() : '');

  api('PATCH', `/incidents/${this.incidentId}/actions/${actionId}/`, form);
}

export default Actions;
