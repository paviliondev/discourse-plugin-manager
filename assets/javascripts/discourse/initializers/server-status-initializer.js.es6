import ApplicationRoute from 'discourse/routes/application';
import ServerStatus from "../models/server-status";
import Topic from 'discourse/models/topic';
import { ajax } from 'discourse/lib/ajax';

export default {
  name: 'server-status',
  initialize() {
    ApplicationRoute.reopen({
      afterModel(model) {
        return ajax('/server-status/status').then(result => {
          this.controllerFor('application').setProperties({
            updateTopic: result.update,
            discourseStatus: ServerStatus.create(result.discourse),
            pluginStats: result.plugins.map(p => ServerStatus.create(p)),
            incompatiblePluginStats: result.incompatible_plugins.map(p => ServerStatus.create(p))
          })
        })
      }
    })
  }
}