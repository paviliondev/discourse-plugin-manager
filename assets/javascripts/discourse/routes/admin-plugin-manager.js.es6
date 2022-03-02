import DiscourseRoute from "discourse/routes/discourse";
import Plugin from "../models/plugin";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return Plugin.list();
  },

  setupController(controller, model) {
    const plugins = A(
      model.plugins.map((plugin) => Plugin.create(plugin)) || []
    );
    controller.setProperties({ plugins });
  },
});
