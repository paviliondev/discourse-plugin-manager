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
          const discourseParams = Object.assign({},
            result.discourse,
            { url: "https://github.com/discourse/discourse" }
          );
          const compatiablePlugins = result.plugins.map(p => ServerStatus.create(p));
          
          let props = {
            updateTopic: result.update,
            discourseStatus: ServerStatus.create(discourseParams),
            compatiablePlugins,
            pluginCounts: { compatible: compatiablePlugins.length }
          }
                    
          if (result.incompatible_plugins) {
            const incompatiblePlugins = result.incompatible_plugins.map(p => ServerStatus.create(p));
            props.incompatiblePlugins = incompatiblePlugins;
            
            if (incompatiblePlugins.length) {
              props.pluginCounts.incompatible = incompatiblePlugins.length;
            }
          }
                    
          this.controllerFor('application').setProperties(props);
        })
      }
    })
  }
}