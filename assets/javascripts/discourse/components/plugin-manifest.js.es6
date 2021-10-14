import Component from "@ember/component";
import PluginStatus from "../models/plugin-status";
import { A } from "@ember/array";
import { observes } from "discourse-common/utils/decorators";
import { INPUT_DELAY } from "discourse-common/config/environment";
import discourseDebounce from "discourse/lib/debounce";

export default Component.extend({
  classNames: 'plugin-manifest',
  page: 0,
  filter: null,
  order: null,
  asc: null,

  @observes("filter", "order", "asc")
  loadPlugins: discourseDebounce(function (append) {
    this.set("loading", true);

    const currentNames = this.plugins.map(p => p.name);
    let params = {
      page: this.page,
      order: this.order,
      asc: this.asc,
      filter: this.filter
    };

    PluginStatus.list(params)
      .then((result) => {
        let plugins = result.plugins;

        if (this.addingPage) {
          this.set('addingPage', false);
          plugins = plugins.filter(p => !currentNames.includes(p.name));
        } else {
          this.set("plugins", A());
        }

        this.get("plugins").pushObjects(
          plugins.map((plugin) => PluginStatus.create(plugin))
        );
      })
      .finally(() => this.set("loading", false));
  }, INPUT_DELAY),
  
  actions: {
    loadMore() {
      let currentPage = this.get("page");
      this.set("page", (currentPage += 1));
      this.set("addingPage", true);
      this.loadPlugins();
    },
  }
})