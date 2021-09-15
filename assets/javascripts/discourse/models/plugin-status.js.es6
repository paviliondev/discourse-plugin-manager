import discourseComputed from "discourse-common/utils/decorators";
import ManagerStatus from "./status";
import { equal } from "@ember/object/computed";

const statusIcons = {
  recommended: "check",
  compatible: "check",
  incompatible: "times"
}

const PluginStatus = ManagerStatus.extend({
  recommended: equal("statusClass", "recommended"),
  compatible: equal("statusClass", "compatible"),
  incompatible: equal("statusClass", "incompatible"),

  @discourseComputed("status", "test_status")
  statusClass(status, testStatus) {
    if (status == 3 && testStatus == 0) return "recommended";
    if (status == 0) return "compatible";
    return "incompatible";
  },

  @discourseComputed("statusClass")
  statusIcon(statusClass) {
    return statusIcons[statusClass];
  }
});

export default PluginStatus;