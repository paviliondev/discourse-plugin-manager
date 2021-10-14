import Component from "@ember/component";
import discourseComputed from 'discourse-common/utils/decorators';
import { notEmpty, or } from "@ember/object/computed";

export default Component.extend({
  classNames: ["plugin-status-detail", "plugin-manager-detail"],
  hasLog: notEmpty("plugin.log"),
  hasMetadata: or("plugin.gitLink", "plugin.test_backend_coverage"),

  @discourseComputed("plugin.status")
  detailTitle(pluginStatus) {
    return I18n.t(`server_status.plugin.${pluginStatus}.detail_title`);
  },

  @discourseComputed("plugin.status")
  detailDescription(pluginStatus) {
    return I18n.t(`server_status.plugin.${pluginStatus}.description`);
  },

  actions: {
    toggleLog() {
      this.toggleProperty('showLog');
    }
  }
});