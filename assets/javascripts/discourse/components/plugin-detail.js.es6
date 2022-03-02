import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: ["plugin-detail", "plugin-manager-detail"],

  @discourseComputed("manifest")
  aboutClass(manifest) {
    return manifest ? "full-width" : "";
  },

  didInsertElement() {
    this._super(...arguments);

    if (this.category) {
      document.body.classList.add("plugin-category");
    }
  },

  willDestroyElement() {
    this._super(...arguments);

    if (this.category) {
      document.body.classList.remove("plugin-category");
    }
  },
});
