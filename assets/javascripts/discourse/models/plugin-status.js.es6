import discourseComputed from "discourse-common/utils/decorators";
import ManagerStatus from "./status";
import { dasherize } from "@ember/string";
import { ajax } from 'discourse/lib/ajax';
import { notEmpty } from "@ember/object/computed";

const statusIcons = {
  recommended: "check-circle",
  compatible: "far-check-circle",
  tests_failing: "far-times-circle",
  incompatible: "times-circle"
}

const PluginStatus = ManagerStatus.extend({
  @discourseComputed("status")
  statusIcon(status) {
    return status ? statusIcons[status] : '';
  },

  @discourseComputed("status")
  statusTitle(status) {
    return status ? I18n.t(`server_status.plugin.${status}.title`) : '';
  },

  @discourseComputed("status")
  statusClass(status) {
    return status ? dasherize(status) : '';
  },

  @discourseComputed("name")
  testLink(name) {
    return `/c/${name}`;
  },

  hasContactEmails: notEmpty('contactEmails'),

  @discourseComputed('contact_emails')
  contactEmails(emails) {
    return emails ? emails.split(',') : [];
  },

  @discourseComputed('authors')
  authorList(authors) {
    return authors ? authors.split(',') : [];
  }
});

PluginStatus.reopenClass({
  list() {
    return ajax('/plugin-manager/status');
  }
});

export default PluginStatus;