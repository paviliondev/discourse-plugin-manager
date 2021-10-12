import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import PluginStatus from "../models/plugin-status";
import I18n from 'I18n';

const pluginStatuses = {
  compatible: 0,
  incompatible: 1
}

const testHosts = {
  github: "Github"
}

export default Component.extend({
  classNameBindings: [':plugin-manager-plugin'],

  @discourseComputed
  pluginStatuses() {
    return Object.keys(pluginStatuses).map(status => ({
      id: pluginStatuses[status],
      name: status
    }));
  },

  @discourseComputed
  testHosts() {
    return Object.keys(testHosts).map(host => ({
      id: host,
      name: testHosts[host]
    }));
  },

  actions: {
    updateContactEmails(emails) {
      this.set("plugin.contact_emails", emails);
    },

    updateNames(names) {
      this.set("plugin.names", names);
    },

    destroy() {
      this.set('destroying', true);
      PluginStatus.destroy(this.plugin.name).then(() => {
        this.set('destroying', false);
      });
    },

    save() {
      this.set('saving', true);
      PluginStatus.save(this.plugin).then(() => {
        this.set('saving', false);
      });
    }
  }
});