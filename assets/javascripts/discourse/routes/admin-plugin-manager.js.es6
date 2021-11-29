import DiscourseRoute from "discourse/routes/discourse";
import PluginManager from "../models/plugin-manager";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return PluginManager.list();
  },

  setupController(controller, model) {
    const plugins = A(
      model.plugins.map((plugin) => PluginManager.create(plugin)) || []
    );
    controller.setProperties({ plugins });
  },
});
