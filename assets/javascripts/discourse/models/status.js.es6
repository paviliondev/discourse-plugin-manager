import discourseComputed from "discourse-common/utils/decorators";
import EmberObject from "@ember/object";

const ManagerStatus = EmberObject.extend({
  @discourseComputed("url", "sha")
  gitLink(url, sha) {
    if (url && sha) {
      return `${url}/commits/${sha}`;
    }
  },

  @discourseComputed("sha")
  shortSha(sha) {
    if (sha) {
      return sha.substr(0, 10);
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
