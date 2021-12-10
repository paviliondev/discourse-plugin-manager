import ApplicationRoute from "discourse/routes/application";
import DiscourseStatus from "../models/discourse-status";
import PluginManager from "../models/plugin-manager";
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "server-status",
  initialize() {
    ApplicationRoute.reopen({
      afterModel() {
        return PluginManager.status().then((result) => {
          this.controllerFor("application").setProperties({
            discourse: DiscourseStatus.create(result.discourse),
            plugins: result.plugins.map((plugin) =>
              PluginManager.create(plugin)
            ),
          });
        });
      },
    });

    withPluginApi("0.8.13", (api) => {
      api.modifyClass("route:discovery-categories", {
        modifyClass: "plugin-manager-server",

        renderTemplate() {
          this.render("discovery/categories", { outlet: "list-container" });
        },
      });
    });
  },
};
