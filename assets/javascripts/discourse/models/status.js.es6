import discourseComputed from "discourse-common/utils/decorators";
import EmberObject from "@ember/object";

const ManagerStatus = EmberObject.extend({
  @discourseComputed("branch_url", "url", "branch")
  branchUrl(branchUrl, url, branch) {
    if (branchUrl) {
      return branchUrl;
    }
    return `${url}/tree/${branch}`;
  },
});

export default ManagerStatus;
