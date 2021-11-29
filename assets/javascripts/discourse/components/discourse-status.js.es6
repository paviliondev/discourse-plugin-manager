import Component from "@ember/component";
import { createPopper } from "@popperjs/core";
import { bind, scheduleOnce } from "@ember/runloop";

export default Component.extend({
  classNames: ["discourse-status"],
  showDiscourseDetail: false,

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

    if (!event.target.closest(`.discourse-status`)) {
      this.set("showDiscourseDetail", false);
    }
  },

  createDiscourseModal() {
    let container = this.element;
    let modal = this.element.querySelector(".discourse-detail");

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
    toggleDiscourseStatus() {
      this.toggleProperty("showDiscourseDetail");

      if (this.showDiscourseDetail) {
        scheduleOnce("afterRender", this, this.createDiscourseModal);
      }
    },
  },
});
