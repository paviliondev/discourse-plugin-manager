import DiscourseStatus from "../models/discourse-status";
import PluginManager from "../models/plugin-manager";
import { withPluginApi } from "discourse/lib/plugin-api";
import { A } from "@ember/array";
import { all } from "rsvp";

export default {
  name: "plugin-manager",
  initialize() {
    withPluginApi("0.8.13", (api) => {
      api.modifyClass("route:discovery-categories", {
        pluginId: "plugin-manager",

        afterModel() {
          return all([this._getDiscourse(), this._getPlugins()]);
        },

        renderTemplate() {
          this.render("discovery/categories", { outlet: "list-container" });
        },

        setupController(controller) {
          this._super(...arguments);
          controller.setProperties({
            discourse: DiscourseStatus.create(this.discourse),
            plugins: A(
              this.plugins.map((plugin) => PluginManager.create(plugin))
            ),
          });
        },

        _getDiscourse() {
          return PluginManager.discourse().then((result) => {
            this.set("discourse", result.discourse);
          });
        },

        _getPlugins() {
          return PluginManager.list().then((result) => {
            this.set("plugins", result.plugins);
          });
        },
      });

      ["discovery.category"].forEach((name) => {
        api.modifyClass(`route:${name}`, {
          pluginId: "plugin-manager",

          afterModel(model) {
            return this._super(...arguments).then(() => {
              let categoryId = model.category.parentCategory
                ? model.category.parentCategory.id
                : model.category.id;

              return PluginManager.categoryPlugin(categoryId).then((result) => {
                if (result.plugin) {
                  this.set(
                    "categoryPlugin",
                    PluginManager.create(result.plugin)
                  );
                }
              });
            });
          },

          setupController(controller, model) {
            this._super(...arguments);

            if (this.categoryPlugin) {
              model.category.set("plugin", this.categoryPlugin);
            }
          },
        });
      });
    });
  },
};
