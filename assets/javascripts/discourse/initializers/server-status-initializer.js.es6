import ApplicationRoute from 'discourse/routes/application';
import DiscourseStatus from "../models/discourse-status";
import PluginStatus from "../models/plugin-status";
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: 'server-status',
  initialize() {
    ApplicationRoute.reopen({
      afterModel(model) {
        return PluginStatus.status().then(result => {
          this.controllerFor('application').setProperties({
            discourse: DiscourseStatus.create(result.discourse),
            plugins: result.plugins.map((plugin) => PluginStatus.create(plugin))
          });
        })
      }
    });

    withPluginApi("0.8.13", (api) => {
      api.modifyClass("route:discovery-categories", {
        renderTemplate() {
          this.render("discovery/categories", { outlet: "list-container" });
        }
      });
    });
  }
}