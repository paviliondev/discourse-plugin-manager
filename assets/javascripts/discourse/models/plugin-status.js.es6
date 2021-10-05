import discourseComputed from "discourse-common/utils/decorators";
import ManagerStatus from "./status";

const statusIcons = {
  recommended: "check",
  compatible: "check",
  incompatible: "times",
  tests_failing: "exclamation-circle"
}

const PluginStatus = ManagerStatus.extend({
  @discourseComputed("status")
  statusIcon(status) {
    return statusIcons[status];
  }
});

export default PluginStatus;