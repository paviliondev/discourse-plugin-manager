import discourseComputed from "discourse-common/utils/decorators";
import EmberObject from "@ember/object";

const ManagerStatus = EmberObject.extend({
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
  },

  @discourseComputed("branch_url", "url", "git_branch")
  branchUrl(branchUrl, url, branch) {
    if (branchUrl) {
      return branchUrl;
    }
    return `${url}/tree/${branch}`;
  },
});

export default ManagerStatus;
