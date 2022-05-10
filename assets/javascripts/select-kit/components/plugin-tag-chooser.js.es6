import TagChooser from "select-kit/components/tag-chooser";
import discourseComputed from "discourse-common/utils/decorators";

export default TagChooser.extend({
  classNames: "plugin-tag-chooser",

  selectKitOptions: {
    allowAny: false,
    none: "server_status.plugin.select_tags"
  },

  @discourseComputed("site.plugin_tags")
  content(pluginTags) {
    return pluginTags.map(t => ({ id: t, name: t }));
  }
});
