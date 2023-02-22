import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: ["plugin-detail", "plugin-manager-detail"],

  @discourseComputed("plugin.documentationCategory.id", "category.id")
  documentationCategory(pluginCategoryId, categoryId) {
    return !categoryId || pluginCategoryId === categoryId;
  },

  @discourseComputed("plugin.supportCategory.id", "category.id")
  supportCategory(pluginCategoryId, categoryId) {
    return pluginCategoryId && pluginCategoryId === categoryId;
  },

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

  click(event) {
    event.stopPropagation();
  },
});
