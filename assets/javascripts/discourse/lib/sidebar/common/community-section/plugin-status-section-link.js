import I18n from "I18n";

import BaseSectionLink from "discourse/lib/sidebar/base-community-section-link";

export default class PluginStatusSectionLink extends BaseSectionLink {
  get name() {
    return "plugins";
  }

  get route() {
    return "plugins";
  }

  get title() {
    return I18n.t("plugin_manager.plugin_status");
  }

  get text() {
    return I18n.t("plugin_manager.plugin_status");
  }

  get prefixType() {
    return "icon";
  }

  get prefixValue() {
    return "plug";
  }
}
