import discourseComputed from "discourse-common/utils/decorators";
import { dasherize } from "@ember/string";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { notEmpty, readOnly } from "@ember/object/computed";
import EmberObject from "@ember/object";
import Category from "discourse/models/category";
import I18n from "I18n";

const statusIcons = {
  unknown: "far-question-circle",
  compatible: "far-check-circle",
  tests_failing: "far-times-circle",
  incompatible: "times-circle",
};

const Plugin = EmberObject.extend({
  @discourseComputed("status.status")
  statusIcon(status) {
    return status ? statusIcons[status] : "";
  },

  @discourseComputed("status.status")
  statusTitle(status) {
    return status ? I18n.t(`server_status.plugin.status.${status}.title`) : "";
  },

  @discourseComputed("status.status")
  statusClass(status) {
    return status ? dasherize(status) : "";
  },

  @discourseComputed("owner")
  ownerClass(owner) {
    return owner ? "" : "no-owner";
  },

  @discourseComputed("name")
  testLink(name) {
    return `/c/${name}`;
  },

  hasContactEmails: notEmpty("contactEmails"),

  @discourseComputed("contact_emails")
  contactEmails(emails) {
    return emails ? emails.split(",") : [];
  },

  @discourseComputed("authors")
  authorList(authors) {
    return authors ? authors.split(",") : [];
  },

  branchUrl: readOnly("branch_url"),
  branch: readOnly("status.branch"),

  @discourseComputed("category_id")
  category(categoryId) {
    return Category.findById(categoryId);
  },

  reload(discourseBranch) {
    Plugin.find(this.name, discourseBranch).then((result) => {
      this.setProperties(result.plugin);
    });
  },
});

Plugin.reopenClass({
  discourse() {
    return ajax("/plugin-manager/discourse");
  },

  list(data) {
    return ajax("/plugin-manager/plugin", {
      type: "GET",
      data,
    }).catch(popupAjaxError);
  },

  find(pluginName, branch) {
    return ajax(`/plugin-manager/plugin/${pluginName}`, {
      type: "GET",
      data: {
        branch,
      },
    }).catch(popupAjaxError);
  },

  categoryPlugin(categoryId, data = {}) {
    return ajax(`/plugin-manager/plugin/category/${categoryId}`, {
      type: "GET",
      data,
    }).catch(popupAjaxError);
  },

  retrieve(data) {
    return ajax("/plugin-manager/plugin/retrieve", {
      type: "GET",
      data,
    }).catch(popupAjaxError);
  },

  save(plugin) {
    return ajax(`/plugin-manager/plugin/${plugin.name}`, {
      type: "PUT",
      data: {
        plugin,
      },
    }).catch(popupAjaxError);
  },

  destroy(pluginName) {
    return ajax(`/plugin-manager/plugin/${pluginName}`, {
      type: "DELETE",
    }).catch(popupAjaxError);
  },
});

export default Plugin;
