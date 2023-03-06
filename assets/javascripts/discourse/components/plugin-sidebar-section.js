import BaseCustomSidebarSection from "discourse/lib/sidebar/base-custom-sidebar-section";
import BaseCustomSidebarSectionLink from "discourse/lib/sidebar/base-custom-sidebar-section-link";
import Category from "discourse/models/category";

export default class extends BaseCustomSidebarSection {
  constructor(siteSettings, site) {
    super(...arguments);
    this.siteSettings = siteSettings;
    this.site = site;
  }

  get name() {
    return "plugins";
  }
  get title() {
    return I18n.t("plugin_manager.title");
  }
  get text() {
    return I18n.t("plugin_manager.title");
  }
  get links() {
    const sidebarLinks = [];
    const supportCatId = Number(
      this.siteSettings.plugin_manager_support_category
    );
    const docsCatId = Number(
      this.siteSettings.plugin_manager_documentation_category
    );
    const parentIds = [supportCatId, docsCatId].map((id) => id);
    const pluginCategoryParents = this.site.categories.filter((c) =>
      parentIds.includes(c.id)
    );
    pluginCategoryParents.forEach((lc) => {
      sidebarLinks.push({
        icon: supportCatId === lc.id ? "far-life-ring" : "book",
        name: lc.name,
        value: `/c/${Category.slugFor(lc)}`,
        models: [lc.slug],
        route: 'discovery.category'
      });
    });

    sidebarLinks.push({
      icon: "far-dot-circle",
      name: I18n.t("plugin_manager.status"),
      value: "/plugins",
      models: [],
      route: 'plugins'
    });

    return sidebarLinks;
  }
};