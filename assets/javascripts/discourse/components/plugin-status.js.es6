import Component from "@ember/component";
import { default as discourseComputed } from 'discourse-common/utils/decorators';
import { notEmpty } from "@ember/object/computed";
import { bind, scheduleOnce } from "@ember/runloop";
import { createPopper } from "@popperjs/core";

export default Component.extend({
  classNameBindings: [":plugin-status", "plugin.statusClass", "plugin.name"],
  hasLog: notEmpty("plugin.log"),

  @discourseComputed(
    "plugin.statusClass",
    "plugin.name",
    "plugin.shortSha",
    "plugin.gitLink",
    "discourse.installed_version",
    "discourse.shortSha",
    "discourse.gitLink"
  )
  detailTitle(
    statusClass,
    pluginName,
    pluginSha,
    pluginGitLink,
    discourseVersion,
    discourseSha,
    discourseGitLink
  ) {
    return I18n.t(`server_status.plugin.${statusClass}.title`, {
      pluginName,
      pluginSha,
      pluginGitLink,
      discourseVersion,
      discourseSha,
      discourseGitLink
    });
  },

  @discourseComputed("plugin.statusClass", "plugin.name")
  detailDescription(statusClass, pluginName) {
    return I18n.t(`server_status.plugin.${statusClass}.description`, { pluginName });
  },

  click(e) {
    if (!$(e.target).closest('.show-log').length) {
      if (this.showDetail) {
        this.setProperties({
          showDetail: false,
          showLog: false
        });
      } else {
        this.set("showDetail", true);
        scheduleOnce("afterRender", this, this.createDetailsModal);
      }
    }
  },

  didInsertElement() {
    $(document).on("click", bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off("click", bind(this, this.documentClick));
  },

  documentClick(e) {
    if (this._state === "destroying") { return; }
    let $target = $(e.target);

    if (!$target.closest(this.element).length) {
      this.setProperties({
        showDetail: false,
        showLog: false
      });
    }
  },

  createDetailsModal() {
    let container = document.querySelector(`.plugin-status.${this.plugin.name}`);
    let modal = document.querySelector(`.plugin-status.${this.plugin.name} .details`);

    this._popper = createPopper(
      container,
      modal, {
        strategy: "absolute",
        placement: "bottom-start",
        modifiers: [
          {
            name: "preventOverflow",
          },
          {
            name: "offset",
            options: {
              offset: [0, 5],
            },
          },
        ],
      }
    );
  },

  actions: {
    toggleLog() {
      this.toggleProperty('showLog');
    }
  }
})