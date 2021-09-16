import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { bind } from "@ember/runloop";

export default Component.extend({
  classNameBindings: [':plugin-list', 'list.status'],
  learnMoreUrl: 'https://thepavilion.io/t/4822',
  showStatusDescription: false,

  @discourseComputed('list.status')
  listTitle(status) {
    return I18n.t(`server_status.plugin.${status}.title`);
  },

  @discourseComputed('list.status')
  statusDescription(status) {
    return I18n.t(`server_status.plugin.${status}.description`);
  },

  didInsertElement() {
    $(document).on(`mouseup.status-description.${this.list.status}`, bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off(`mouseup.status-description.${this.list.status}`, bind(this, this.documentClick));
  },

  documentClick(e) {
    if (this._state === "destroying") { return; }
    const $target = $(e.target);
    const status = this.list.status;

    if (!$target.closest(`.plugin-list.${status} .plugin-list-title, .plugin-list.${status} .status-description`).length) {
      this.set('showStatusDescription', false);
    }
  },

  actions: {
    toggleStatusDescription() {
      this.toggleProperty('showStatusDescription');
    }
  }
});