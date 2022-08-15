import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: ['plugin-actions'],

  @discourseComputed('site.mobileView')
  issueLabel(mobileView) {
    return mobileView ? null : "server_status.plugin.issues.label";
  },

  @discourseComputed('site.mobileView')
  documentationLabel(mobileView) {
    return mobileView ? null : "server_status.plugin.documentation.label"
  }
});
