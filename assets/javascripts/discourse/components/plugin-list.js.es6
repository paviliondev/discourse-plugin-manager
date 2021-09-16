import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { bind } from "@ember/runloop";

export default Component.extend({
  classNames: 'plugin-list',
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
    $(document).on("click", bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off("click", bind(this, this.documentClick));
  },

  documentClick(e) {
    if (this._state === "destroying") { return; }
    let $target = $(e.target);

    if (!$target.closest(this.element).length) {
      this.set('showStatusDescription', false);
    }
  },

  actions: {
    toggleStatusDescription() {
      this.toggleProperty('showStatusDescription');
    }
  }
});