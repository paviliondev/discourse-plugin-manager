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
        modifyClass: "plugin-manager",

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
    });
  },
};
