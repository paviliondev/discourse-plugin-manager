import Controller from "@ember/controller";
import PluginManager from "../models/plugin-manager";
import showModal from "discourse/lib/show-modal";

export default Controller.extend({
  actions: {
    addPlugin(plugin) {
      plugin = plugin || PluginManager.create({ new: true });
      this.get("plugins").unshiftObject(plugin);
    },

    removePlugin(plugin) {
      this.get("plugins").removeObject(plugin);
    },

    editPlugin(plugin) {
      let originalPlugin = plugin;
      let modalController = showModal("plugin-manager-plugin-editor", {
        model: plugin,
      });
      modalController.setProperties({
        afterSave: (addPlugin) => {
          this.send("removePlugin", originalPlugin);
          this.send("addPlugin", addPlugin);
        },
        afterDestroy: (removePlugin) => {
          this.send("removePlugin", removePlugin);
        },
      });
    },
  },
});
