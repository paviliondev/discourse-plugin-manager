import Component from "@ember/component";
import { default as discourseComputed } from 'discourse-common/utils/decorators';

export default Component.extend({
  classNames: 'discourse-status',
  
  @discourseComputed('inUpdatePeriod')
  updateClass(inUpdatePeriod) {
    let classes = 'update-topic';
    if (inUpdatePeriod) {
      classes += 'btn-success';
    }
    return classes;
  },
  
  @discourseComputed('inUpdatePeriod')
  updateTitle(inUpdatePeriod) {
    return `server_status.${inUpdatePeriod ? 'current_period' : 'next_period'}`;
  },
});