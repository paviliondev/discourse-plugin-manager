import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";

export default Component.extend({
  classNames: ["plugin-actions"],
  router: service(),

  @discourseComputed("site.mobileView", "textOnly")
  issueLabel(mobileView, textOnly) {
    return (mobileView || textOnly) ? null : "server_status.plugin.issues.label";
  },

  @discourseComputed("site.mobileView", "textOnly")
  documentationLabel(mobileView, textOnly) {
    return (mobileView || textOnly) ? null : "server_status.plugin.documentation.label";
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
