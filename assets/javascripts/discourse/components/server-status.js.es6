import Component from '@ember/component';
import { getOwner } from 'discourse-common/lib/get-owner';
import { default as discourseComputed } from 'discourse-common/utils/decorators';

export default Component.extend({
  classNameBindings: [':server-status', 'inUpdatePeriod', 'visible'],
  maximized: false,
  
  init() {
    this._super(...arguments);
    const container = getOwner(this)
    const controller = container.lookup('controller:application');
    const router = container.lookup("router:main");

    let props = {
      router,
      discourseStatus: controller.get('discourseStatus'),
      compatiablePlugins: controller.get('compatiablePlugins'),
      incompatiblePlugins: controller.get('incompatiblePlugins'),
      pluginCounts: controller.get('pluginCounts')
    }
    
    let dateUtilities;
    try {
      dateUtilities = requirejs('discourse/plugins/discourse-events/discourse/lib/date-utilities');
    } catch(error) {
      console.warn("Events plugin missing");
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
  
  @discourseComputed('router.currentPath')
  visible(currentPath) {
    return currentPath && currentPath.indexOf('admin') === -1;
  },
  
  click() {
    this.toggleProperty('maximized');
  },
  
  @discourseComputed('maximized')
  bottomClass(maximized) {
    return maximized ? 'maximized' : '';
  }
});