import Component from "@ember/component";
import { bind, scheduleOnce } from "@ember/runloop";
import { createPopper } from "@popperjs/core";
import discourseComputed from "discourse-common/utils/decorators";
import Category from "discourse/models/category";
import DiscourseURL from "discourse/lib/url";

export default Component.extend({
  tagName: "tr",
  classNameBindings: [
    ":plugin-status",
    "plugin.statusClass",
    "plugin.name",
    "plugin.ownerClass",
  ],
  showPluginDetail: false,
  showStatusDetail: false,

  didInsertElement() {
    $(document).on("click", bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off("click", bind(this, this.documentClick));
  },

  click(e) {
    if (!e.target.closest(".btn-plugin, .btn-owner-logo, .status-badge")) {
      DiscourseURL.routeTo(this.pluginCategory.url);
    }
  },

  documentClick(event) {
    if (this._state === "destroying") {
      return;
    }

    if (
      !event.target.closest(
        `.plugin-status.${this.plugin.name} .name-container`
      )
    ) {
      this.set("showPluginDetail", false);
    }

    if (
      !event.target.closest(
        `.plugin-status.${this.plugin.name} .owner-container`
      )
    ) {
      this.set("showOwnerDetail", false);
    }
  },

  createPluginDetailModal() {
    let container = this.element.querySelector(".name-container");
    let modal = this.element.querySelector(".plugin-detail");
    this.createModal(container, modal);
  },

  createOwnerDetailModal() {
    let container = this.element.querySelector(".owner-container");
    let modal = this.element.querySelector(".owner-detail");
    this.createModal(container, modal);
  },

  createModal(container, modal) {
    this._popper = createPopper(container, modal, {
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
    });
  },

  @discourseComputed("plugin.contactEmails", "plugin.owner")
  supportLink(contactEmails, owner) {
    if (owner && owner.name && owner.name.toLowerCase() === "pavilion") {
      return `https://thepavilion.io`;
    }
    return `mailto:${contactEmails[0]}`;
  },

  @discourseComputed("plugin.category_id")
  pluginCategory(categoryId) {
    return Category.findById(categoryId);
  },

  actions: {
    togglePluginDetail() {
      this.toggleProperty("showPluginDetail");

      if (this.showPluginDetail) {
        scheduleOnce("afterRender", this, this.createPluginDetailModal);
      }
    },

    toggleOwnerDetail() {
      this.toggleProperty("showOwnerDetail");

      if (this.showOwnerDetail) {
        scheduleOnce("afterRender", this, this.createOwnerDetailModal);
      }
    },
  },
});
