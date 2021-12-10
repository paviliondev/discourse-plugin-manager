import Controller from "@ember/controller";
import PluginManager from "../models/plugin-manager";
import showModal from "discourse/lib/show-modal";

export default Controller.extend({
  removePlugin(pluginName) {
    const plugins = this.get("plugins");
    const removePlugin = plugins.findBy("name", pluginName);
    plugins.removeObject(removePlugin);
  },

  addPlugin(plugin) {
    this.get("plugins").unshiftObject(plugin);
  },

  actions: {
    addPlugin(plugin) {
      let model = plugin || PluginManager.create({ new: true });
      let controller = showModal("plugin-manager-plugin-editor", { model });

      controller.setProperties({
        afterSave: (addedPlugin) => (this.addPlugin(addedPlugin))
      });
      controller.setupEvents();
    },

    removePlugin(plugin) {
      this.set("destroying", true);
      PluginManager.destroy(plugin.name).then((result) => {
        if (result.success) {
          this.removePlugin(result.plugin_name);
        }
        this.set("destroying", false);
      });
    },

    editPlugin(plugin) {
      let originalPlugin = plugin;
      let controller = showModal("plugin-manager-plugin-editor", { model: plugin });

      controller.setProperties({
        afterSave: (savedPlugin) => {
          this.removePlugin(originalPlugin.name);
          this.addPlugin(savedPlugin);
        },
        afterDestroy: (removedPlugin) => (this.removePlugin(removedPlugin))
      });
      controller.setupEvents();
    },
  },
});
