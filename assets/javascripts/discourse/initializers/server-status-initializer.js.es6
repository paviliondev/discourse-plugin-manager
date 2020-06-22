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
          let discourseParams = Object.assign({},
            result.discourse,
            { url: "https://github.com/discourse/discourse" }
          );
          
          let props = {
            updateTopic: result.update,
            discourseStatus: ServerStatus.create(discourseParams),
            pluginStats: result.plugins.map(p => ServerStatus.create(p)),
          }
          
          if (result.incompatible_plugins) {
            props.incompatiblePluginStats = result.incompatible_plugins.map(p => 
              ServerStatus.create(p)
            )
          }
          
          this.controllerFor('application').setProperties(props);
        })
      }
    })
  }
}