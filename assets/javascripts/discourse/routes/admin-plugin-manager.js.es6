import DiscourseRoute from "discourse/routes/discourse";
import PluginStatus from "../models/plugin-status";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return PluginStatus.list();
  },

  setupController(controller, model) {
    const plugins = A(model.plugins.map((plugin) => PluginStatus.create(plugin)) || []);
    controller.setProperties({ plugins });
  }
});