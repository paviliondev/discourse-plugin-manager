import ApplicationRoute from 'discourse/routes/application';
import DiscourseStatus from "../models/discourse-status";
import PluginStatus from "../models/plugin-status";

export default {
  name: 'server-status',
  initialize() {
    ApplicationRoute.reopen({
      afterModel(model) {
        return PluginStatus.list().then(result => {
          this.controllerFor('application').setProperties({
            discourse: DiscourseStatus.create(result.discourse),
            plugins: result.plugins.map((plugin) => PluginStatus.create(plugin))
          });
        })
      }
    })
  }
}