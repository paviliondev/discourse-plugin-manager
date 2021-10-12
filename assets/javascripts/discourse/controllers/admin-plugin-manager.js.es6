import Controller from "@ember/controller";
import PluginStatus from "../models/plugin-status";

export default Controller.extend({
  actions: {
    addPlugin() {
      this.get("plugins").unshiftObject(
        PluginStatus.create({})
      );
    }
  }
});
