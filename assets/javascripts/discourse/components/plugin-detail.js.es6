import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: ["plugin-detail", "plugin-manager-detail"],

  @discourseComputed("manifest")
  aboutClass(manifest) {
    return manifest ? "full-width" : "";
  },

  @discourseComputed("category")
  issueCategory(category) {
    const issueCategoryName = this.siteSettings
      .plugin_manager_issues_local_subcategory_name;
    return category.subcategories.find((c) => c.name === issueCategoryName);
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
