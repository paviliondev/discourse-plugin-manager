import Component from "@ember/component";
import { bind, scheduleOnce } from "@ember/runloop";
import { createPopper } from "@popperjs/core";

export default Component.extend({
  tagName: 'tr',
  classNameBindings: [":plugin-status", "plugin.statusClass", "plugin.name"],
  showPluginDetail: false,
  showStatusDetail: false,

  didInsertElement() {
    $(document).on("click", bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off("click", bind(this, this.documentClick));
  },

  documentClick(event) {
    if (this._state === "destroying") { return; }

    if (!event.target.closest(`.plugin-status.${this.plugin.name} .status-container`)) {
      this.set('showStatusDetail', false);
    }

    if (!event.target.closest(`.plugin-status.${this.plugin.name} .name-container`)) {
      this.set('showPluginDetail', false);
    }

    if (!event.target.closest(`.plugin-status.${this.plugin.name} .owner-container`)) {
      this.set('showOwnerDetail', false);
    }
  },

  createPluginDetailModal() {
    let container = this.element.querySelector('.name-container');
    let modal = this.element.querySelector('.plugin-detail');
    this.createModal(container, modal);
  },

  createStatusDetailModal() {
    let container = this.element.querySelector('.status-container');
    let modal = this.element.querySelector('.plugin-status-detail');
    this.createModal(container, modal);
  },

  createOwnerDetailModal() {
    let container = this.element.querySelector('.owner-container');
    let modal = this.element.querySelector('.owner-detail');
    this.createModal(container, modal);
  },

  createModal(container, modal) {
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
    togglePluginDetail() {
      this.toggleProperty('showPluginDetail');

      if (this.showPluginDetail) {
        scheduleOnce("afterRender", this, this.createPluginDetailModal);
      }
    },

    toggleStatusDetail() {
      if (!event.target.closest(`.plugin-status.${this.plugin.name} .log`)) {
        this.toggleProperty('showStatusDetail');

        if (this.showStatusDetail) {
          scheduleOnce("afterRender", this, this.createStatusDetailModal);
        }
      }
    },

    toggleOwnerDetail() {
      this.toggleProperty('showOwnerDetail');

      if (this.showOwnerDetail) {
        scheduleOnce("afterRender", this, this.createOwnerDetailModal);
      }
    }
  }
})