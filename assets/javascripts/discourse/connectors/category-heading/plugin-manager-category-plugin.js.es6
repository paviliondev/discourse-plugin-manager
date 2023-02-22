import Plugin from "../../models/plugin";
import Discourse from "../../models/discourse";

export default {
  setupComponent(attrs) {
    let category = attrs.category;

    function observerCallback() {
      if (this._state === "destroying") {
        return;
      }

      Plugin.categoryPlugin(category.id, {
        branch: category.discourse.branch,
      }).then((result) => {
        category.setProperties({
          discourse: Discourse.create({ branch: result.branch }),
          plugin: Plugin.create(result.plugin),
        });

        category.discourse.addObserver("branch", observerCallback);
      });
    }

    if (category.discourse) {
      category.discourse.addObserver("branch", observerCallback);
    }
  },
};
