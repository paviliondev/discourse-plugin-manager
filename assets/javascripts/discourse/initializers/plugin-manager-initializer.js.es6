import Plugin from "../models/plugin";
import Discourse from "../models/discourse";
import { withPluginApi } from "discourse/lib/plugin-api";
import discourseComputed from "discourse-common/utils/decorators";

import EverythingSectionLink from "discourse/lib/sidebar/common/community-section/everything-section-link";
import AdminSectionLink from "discourse/lib/sidebar/user/community-section/admin-section-link";
import DocumentationSectionLink from "../lib/sidebar/common/community-section/documentation-section-link";
import PluginStatusSectionLink from "../lib/sidebar/common/community-section/plugin-status-section-link";
import SupportSectionLink from "../lib/sidebar/common/community-section/support-section-link";

export default {
  name: "plugin-manager",
  initialize(container) {
    const messageBus = container.lookup("service:message-bus");

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

      api.modifyClass("component:sidebar/user/community-section", {
        get defaultMainSectionLinks() {
          return [
            EverythingSectionLink,
            DocumentationSectionLink,
            SupportSectionLink,
            PluginStatusSectionLink,
            AdminSectionLink,
          ];
        },
      });

      api.modifyClass("component:sidebar/anonymous/community-section", {
        get defaultMainSectionLinks() {
          return [
            EverythingSectionLink,
            DocumentationSectionLink,
            SupportSectionLink,
            PluginStatusSectionLink,
          ];
        },
      });
    });
  },
};
