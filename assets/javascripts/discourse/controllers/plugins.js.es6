import Controller from "@ember/controller";
import { observes } from "discourse-common/utils/decorators";

export default Controller.extend({
  queryParams: ["branch"],

  @observes("discourse.branch")
  setBranch() {
    this.set("branch", this.discourse.branch);
  },
});
