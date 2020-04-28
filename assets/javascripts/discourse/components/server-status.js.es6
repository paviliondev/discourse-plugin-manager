import Component from '@ember/component';
import { getOwner } from 'discourse-common/lib/get-owner';
import { default as discourseComputed } from 'discourse-common/utils/decorators';

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
    
    let dateUtilities;
    try {
      dateUtilities = requirejs('discourse/plugins/discourse-events/discourse/lib/date-utilities');
    } catch(error) {
      console.error(error);
    }
    
    const updateTopic = controller.get('updateTopic');
    if (updateTopic && updateTopic.event && dateUtilities) {
      const { start, end, allDay, multiDay } = dateUtilities.setupEvent(updateTopic.event);
      const { startIsSame, endIsSame, isBetween, daysLeft } = dateUtilities.eventCalculations(
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