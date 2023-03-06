import Plugin from "../models/plugin";
import Discourse from "../models/discourse";
import Category from "discourse/models/category";
import { withPluginApi } from "discourse/lib/plugin-api";
import discourseComputed from "discourse-common/utils/decorators";
import PluginSidebarSection from "../components/plugin-sidebar-section";
import I18n from "I18n";

export default {
  name: "plugin-manager",
  initialize(container) {
    const messageBus = container.lookup("service:message-bus");
    const site = container.lookup("service:site");
    const siteSettings = container.lookup("service:site-settings");
    const currentUser = container.lookup("service:current-user");

    currentUser.set('sidebar_sections', [
      new PluginSidebarSection(siteSettings, site),
      ...currentUser.sidebar_sections
    ]);

    messageBus.subscribe(
      "/plugin-manager/status-updated",
      function (pluginName) {
        const pluginsController = container.lookup("controller:plugins");
        const plugin = pluginsController.plugins.findBy("name", pluginName);
        const discourse = pluginsController.discourse;

        if (plugin && discourse) {
          plugin.reload(discourse.branch);
        }
      }
    );

    withPluginApi("1.6.0", (api) => {
      api.modifyClass("route:discovery.category", {
        pluginId: "plugin-manager",

        afterModel(model) {
          return this._super(...arguments).then(() => {
            return Plugin.categoryPlugin(model.category.id).then((result) => {
              this.setProperties(result);
            });
          });
        },

        setupController() {
          this._super(...arguments);

          if (this.plugin) {
            const branch = this.branch;
            const discourse = Discourse.create({ branch });
            const plugin = Plugin.create(this.plugin);

            this.controllerFor("navigation/category").category.setProperties({
              discourse,
              plugin,
            });
          }
        },
      });

      api.modifyClass("controller:navigation/category", {
        pluginId: "plugin-manager",

        @discourseComputed("category", "category.parentCategory")
        displayCategory(category, parentCategory) {
          return parentCategory || category;
        },

        @discourseComputed("site.categories")
        pluginCategories(categories) {
          return categories.filter((c) => c.for_plugin);
        },
      });
    });
  },
};
