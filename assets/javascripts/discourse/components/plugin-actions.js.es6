import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";

export default Component.extend({
  classNames: ["plugin-actions"],
  router: service(),

  @discourseComputed("site.mobileView")
  issueLabel(mobileView) {
    return mobileView ? null : "server_status.plugin.issues.label";
  },

  @discourseComputed("site.mobileView")
  documentationLabel(mobileView) {
    return mobileView ? null : "server_status.plugin.documentation.label";
  },

  @discourseComputed("router.currentURL")
  issuesClass(currentURL) {
    return currentURL.includes("/issues/") ? "btn-primary" : "";
  },

  @discourseComputed("router.currentURL")
  documentationClass(currentURL) {
    return currentURL.includes("/documentation/") ? "btn-primary" : "";
  },
});
