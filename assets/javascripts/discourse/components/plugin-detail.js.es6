import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: ["plugin-detail"],

  @discourseComputed("manifest")
  aboutClass(manifest) {
    return manifest ? "full-width" : "";
  },
});
