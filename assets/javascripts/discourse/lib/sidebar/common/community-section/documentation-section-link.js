import { helperContext } from "discourse-common/lib/helpers";
import BaseSectionLink from "discourse/lib/sidebar/base-community-section-link";
import Category from "discourse/models/category";

export default class DocumentationSectionLink extends BaseSectionLink {
  constructor() {
    super(...arguments);
    const { site, siteSettings } = helperContext();
    const categoryId = Number(siteSettings.plugin_manager_documentation_category);
    this.category = site.categories.find((c) => c.id === categoryId);
  }

  get name() {
    return "plugin";
  }

  get route() {
    return "discovery.category";
  }

  get model() {
    return `${Category.slugFor(this.category)}/${this.category?.id}`;
  }

  get title() {
    return this.category?.name;
  }

  get text() {
    return this.category?.name;
  }

  get prefixType() {
    return "icon";
  }

  get prefixValue() {
    return "book";
  }
}
