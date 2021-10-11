import Component from "@ember/component";
import discourseComputed from 'discourse-common/utils/decorators';
import { notEmpty } from "@ember/object/computed";

export default Component.extend({
  classNames: "plugin-status-detail",
  hasLog: notEmpty("plugin.log"),

  @discourseComputed(
    "plugin.status",
    "plugin.display_name",
    "discourse.git_branch",
  )
  detailTitle(
    pluginStatus,
    pluginName,
    discourseBranch,
  ) {
    return I18n.t(`server_status.plugin.${pluginStatus}.detail_title`, {
      pluginName,
      discourseBranch
    });
  },

  actions: {
    toggleLog() {
      this.toggleProperty('showLog');
    }
  }
});