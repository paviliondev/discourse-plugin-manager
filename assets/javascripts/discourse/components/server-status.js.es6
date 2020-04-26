import Component from '@ember/component';
import { getOwner } from 'discourse-common/lib/get-owner';
import { default as discourseComputed } from 'discourse-common/utils/decorators';
import { eventCalculations, setupEvent } from 'discourse/plugins/discourse-events/discourse/lib/date-utilities';

export default Component.extend({
  classNameBindings: [':server-status', 'inUpdatePeriod', 'visible'],
  
  init() {
    this._super(...arguments);
    const container = getOwner(this)
    const controller = container.lookup('controller:application');
    const router = container.lookup("router:main");

    let props = {
      router,
      discourse: controller.get('discourseStatus'),
      plugins: controller.get('pluginsStatus')
    }
    
    const updateTopic = controller.get('updateTopic');
    if (updateTopic && updateTopic.event) {
      const { start, end, allDay, multiDay } = setupEvent(updateTopic.event);
      const { startIsSame, endIsSame, isBetween, daysLeft } = eventCalculations(
        moment(),
        start,
        end,
      )
      props.updateTopic = updateTopic;
      props.inUpdatePeriod = startIsSame || endIsSame || isBetween;
    }

    this.setProperties(props);
  },
  
  @discourseComputed('inUpdatePeriod')
  updateClass(inUpdatePeriod) {
    let classes = 'update-topic btn ';
    if (inUpdatePeriod) {
      classes += 'btn-success';
    } else {
      classes += 'btn-primary';
    }
    return classes;
  },
  
  @discourseComputed('inUpdatePeriod')
  updateTitle(inUpdatePeriod) {
    return `discourse_server_status.${inUpdatePeriod ? 'current_period' : 'next_period'}`;
  },
  
  @discourseComputed('router.currentPath')
  visible(currentPath) {
    return currentPath && currentPath.indexOf('admin') === -1;
  }
});