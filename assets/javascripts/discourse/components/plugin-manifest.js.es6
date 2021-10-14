import Component from "@ember/component";
import PluginStatus from "../models/plugin-status";
import { A } from "@ember/array";
import { observes } from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: 'plugin-manifest',
  page: 0,
  filter: null,
  order: null,
  asc: null,
  canLoadMore: true,

  @observes("filter", "order", "asc")
  triggerLoadPlugins() {
    this.setProperties({
      page: 0,
      canLoadMore: true
    });
    this.loadPlugins(false);
  },

  loadPlugins(addingPage) {
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

        if (addingPage) {
          plugins = plugins.filter(p => !currentNames.includes(p.name));

          if (plugins.length === 0) {
            this.set("canLoadMore", false);
            return;
          }
        } else {
          this.set("plugins", A());
        }

        this.get("plugins").pushObjects(
          plugins.map((plugin) => PluginStatus.create(plugin))
        );
      })
      .finally(() => this.set("loading", false));
  },

  actions: {
    loadMore() {
      if (this.canLoadMore) {
        let currentPage = this.get("page");
        this.set("page", (currentPage += 1));
        this.loadPlugins(true);
      }
    },
  }
})