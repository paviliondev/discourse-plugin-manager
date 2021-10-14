import Component from "@ember/component";
import discourseComputed from 'discourse-common/utils/decorators';
import { notEmpty } from "@ember/object/computed";

export default Component.extend({
  classNames: ["plugin-status-detail", "plugin-manager-detail"],
  hasLog: notEmpty("plugin.log"),

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