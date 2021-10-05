import Component from "@ember/component";
import { default as discourseComputed } from 'discourse-common/utils/decorators';
import { notEmpty } from "@ember/object/computed";
import { bind, scheduleOnce } from "@ember/runloop";
import { createPopper } from "@popperjs/core";
import { dasherize } from "@ember/string";

export default Component.extend({
  classNameBindings: [":plugin-status", "statusClass", "plugin.name"],
  hasLog: notEmpty("plugin.log"),

  @discourseComputed("plugin.status")
  statusClass(status) {
    return dasherize(status);
  },

  @discourseComputed(
    "plugin.status",
    "plugin.name",
    "discourse.installed_version",
  )
  detailTitle(
    pluginStatus,
    pluginName,
    discourseVersion,
  ) {
    return I18n.t(`server_status.plugin.${pluginStatus}.detail_title`, {
      pluginName,
      discourseVersion
    });
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