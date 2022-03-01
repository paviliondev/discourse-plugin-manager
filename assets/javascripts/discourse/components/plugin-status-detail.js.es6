import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { notEmpty } from "@ember/object/computed";
import I18n from "I18n";

export default Component.extend({
  classNames: ["plugin-status-detail", "plugin-manager-detail"],
  hasLog: notEmpty("plugin.log"),

  @discourseComputed(
    "plugin.status",
    "plugin.name",
    "plugin.branch",
    "discourse.branch"
  )
  detailDescription(pluginStatus, pluginName, pluginBranch, discourseBranch) {
    return I18n.t(`server_status.plugin.status.${pluginStatus}.description`, {
      plugin_name: pluginName,
      plugin_branch: pluginBranch,
      discourse_branch: discourseBranch,
    });
  },

  @discourseComputed("plugin.status")
  detailTitle(pluginStatus) {
    return I18n.t(`server_status.plugin.status.${pluginStatus}.detail_title`);
  },

  actions: {
    toggleLog() {
      this.toggleProperty("showLog");
    },
  },
});
