import TagChooser from "select-kit/components/tag-chooser";
import { makeArray } from "discourse-common/lib/helpers";

export default TagChooser.extend({
  classNames: "plugin-tag-chooser",

  selectKitOptions: {
    allowAny: false,
    none: "server_status.plugin.select_tags",
  },

  search(query) {
    const selectedTags = makeArray(this.tags).filter(Boolean);
    let pluginTags = this.site.plugin_tags;

    if (selectedTags) {
      pluginTags = pluginTags.filter((tag) => !selectedTags.includes(tag));
    }

    if (query) {
      pluginTags = pluginTags.filter((tag) => tag.includes(query));
    }

    return pluginTags.map((tag) => ({ id: tag, name: tag }));
  },
});
