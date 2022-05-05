import Component from "@ember/component";
import { createPopper } from "@popperjs/core";
import { bind, scheduleOnce } from "@ember/runloop";

export default Component.extend({
  classNameBindings: [":plugin-status-button", "plugin.name"],
  showLabel: true,

  didInsertElement() {
    $(document).on("click", bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off("click", bind(this, this.documentClick));
  },

  documentClick(event) {
    if (this._state === "destroying") {
      return;
    }

    if (!event.target.closest(`.plugin-status-button.${this.plugin.name}`)) {
      this.set("showStatusDetail", false);
    }
  },

  createStatusDetailModal() {
    let container = this.element;
    let modal = this.element.querySelector(".plugin-status-detail");
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

  actions: {
    toggleStatusDetail() {
      if (!event.target.closest(`.plugin-status.${this.plugin.name} .log`)) {
        this.toggleProperty("showStatusDetail");

        if (this.showStatusDetail) {
          scheduleOnce("afterRender", this, this.createStatusDetailModal);
        }
      }
    },
  },
});
