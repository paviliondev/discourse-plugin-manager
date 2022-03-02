import Discourse from "../models/discourse";
import Plugin from "../models/plugin";
import { withPluginApi } from "discourse/lib/plugin-api";
import { A } from "@ember/array";
import { observes } from "discourse-common/utils/decorators";

export default {
  name: "plugin-manager",
  initialize() {
    withPluginApi("0.8.13", (api) => {
      api.modifyClass("route:discovery-categories", {
        pluginId: "plugin-manager",

        queryParams: {
          branch: {
            refreshModel: true,
          },
        },

        afterModel() {
          return this._getPlugins();
        },

        renderTemplate() {
          this.render("discovery/categories", { outlet: "list-container" });
        },

        setupController(controller) {
          this._super(...arguments);

          const branch = this.branch;
          const discourse = Discourse.create({ branch });
          const plugins = A(
            this.plugins.map((plugin) => Plugin.create(plugin))
          );

          controller.setProperties({
            discourse,
            plugins,
          });
        },

        _getPlugins() {
          const params = this.paramsFor("discovery.categories");
          return Plugin.list({ branch: params.branch }).then((result) => {
            this.setProperties(result);
          });
        },
      });

      api.modifyClass("controller:discovery/categories", {
        queryParams: ["branch"],

        @observes("discourse.branch")
        setBranch() {
          this.set("branch", this.discourse.branch);
        },
      });

      api.modifyClass("route:discovery.category", {
        pluginId: "plugin-manager",

        afterModel(model) {
          return this._super(...arguments).then(() => {
            let categoryId = model.category.parentCategory
              ? model.category.parentCategory.id
              : model.category.id;

            return Plugin.categoryPlugin(categoryId).then((result) => {
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
    });
  },
};
