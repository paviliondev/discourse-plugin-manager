import Component from "@ember/component";
import PluginStatus from "../models/plugin-status";
import { A } from "@ember/array";
import { observes } from "discourse-common/utils/decorators";
import { INPUT_DELAY } from "discourse-common/config/environment";
import discourseDebounce from "discourse/lib/debounce";

export default Component.extend({
  classNames: 'plugin-manifest',
  page: 0,
  canLoadMore: true,

  @observes("filter")
  loadPlugins: discourseDebounce(function () {
    if (!this.canLoadMore) {
      return;
    }

    this.set("loading", true);

    const page = this.page;
    let params = { page };

    const filter = this.filter;
    if (filter) {
      params.filter = filter;
    }

    PluginStatus.list(params)
      .then((result) => {
        const plugins = result.plugins;

        if (!plugins || plugins.length === 0) {
          this.set("canLoadMore", false);
        }
        if (filter) {
          this.set("plugins", A());
        }
        console.log(filter, plugins)
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
      this.loadPlugins();
    },
  }
})