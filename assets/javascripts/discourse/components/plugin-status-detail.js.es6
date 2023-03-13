import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { notEmpty } from "@ember/object/computed";
import I18n from "I18n";

export default Component.extend({
  classNames: ["plugin-status-detail", "plugin-manager-detail"],
  hasLog: notEmpty("plugin.log"),

  @discourseComputed(
    "plugin.name",
    "plugin.status.status",
    "plugin.status.last_status_at",
    "plugin.status.status_changed_at",
    "plugin.status.branch",
    "discourse.branch"
  )
  detailDescription(
    pluginName,
    pluginStatus,
    pluginLastStatusAt,
    pluginStatusChangedAt,
    pluginBranch,
    discourseBranch
  ) {
    return I18n.t(`plugin_manager.plugin.status.${pluginStatus}.description`, {
      plugin_name: pluginName,
      plugin_branch: pluginBranch,
      discourse_branch: discourseBranch,
      plugin_last_status_at: moment(pluginLastStatusAt).fromNow(),
      plugin_status_changed_at: moment(pluginStatusChangedAt).fromNow(),
    });
  },

  @discourseComputed("plugin.status.status")
  detailTitle(pluginStatus) {
    return I18n.t(`plugin_manager.plugin.status.${pluginStatus}.detail_title`);
  },

  actions: {
    toggleLog() {
      this.toggleProperty("showLog");
    },
  },

  click(event) {
    event.stopPropagation();
  },
});
