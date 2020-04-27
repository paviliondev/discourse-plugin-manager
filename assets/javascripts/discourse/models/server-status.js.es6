import discourseComputed from "discourse-common/utils/decorators";
import EmberObject from "@ember/object";

export default EmberObject.extend({
  @discourseComputed("url", "installed_sha")
  gitLink(url, installedSHA) {
    if (url && installedSHA) {
      return `${url}/commits/${installedSHA}`;
    }
  },

  @discourseComputed("installed_sha")
  shortSha(installedSHA) {
    if (installedSHA) {
      return installedSHA.substr(0, 10);
    }
  }
});