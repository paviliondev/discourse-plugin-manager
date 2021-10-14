import Controller from "@ember/controller";
import discourseComputed from "discourse-common/utils/decorators";
import PluginStatus from "../models/plugin-status";
import I18n from 'I18n';
import { equal } from "@ember/object/computed";
import ModalFunctionality from "discourse/mixins/modal-functionality";

const pluginStatuses = {
  compatible: 0,
  incompatible: 1
}

const testHosts = {
  github: "Github"
}

export default Controller.extend(ModalFunctionality, {
  readOnlyStatus: equal('model.status', 'tests_failing'),

  @discourseComputed('model.new')
  modalTitle(newPlugin) {
    return `admin.plugin_manager.plugin.${newPlugin ? "add" : "edit"}`;
  },

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

  @discourseComputed('model.new', 'model.from_file')
  canDelete(newPlugin, fromFile) {
    return !newPlugin && !fromFile;
  },

  actions: {
    updateContactEmails(emails) {
      this.set("model.contactEmails", emails);
    },

    updateNames(names) {
      this.set("model.names", names);
    },

    destroy() {
      this.set('destroying', true);
      PluginStatus.destroy(this.model.name).then((result) => {
        if (result.success) {
          this.afterDestroy(this.model);
        }
        this.set('destroying', false);
      });
    },

    save() {
      this.set('saving', true);
      const plugin = this.model;
      const attrs = {
        name: plugin.name,
        url: plugin.url,
        authors: plugin.authors,
        about: plugin.about,
        version: plugin.version,
        contact_emails: plugin.contact_emails,
        test_host: plugin.test_host,
        support_url: plugin.support_url,
        test_url: plugin.test_url,
        status: plugin.status
      }

      PluginStatus.save(attrs).then((result) => {
        if (result.success) {
          this.afterSave(this.model);
        }
        this.set('saving', false);
      });
    }
  }
});