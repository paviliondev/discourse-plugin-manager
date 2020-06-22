import discourseComputed from "discourse-common/utils/decorators";
import EmberObject from "@ember/object";

export default EmberObject.extend({
  @discourseComputed("installed_sha")
  gitLink(installedSHA) {
    if (installedSHA) {
      return `https://github.com/discourse/discourse/commits/${installedSHA}`;
    }
  },

  @discourseComputed("installed_sha")
  shortSha(installedSHA) {
    if (installedSHA) {
      return installedSHA.substr(0, 10);
    }
  }
});