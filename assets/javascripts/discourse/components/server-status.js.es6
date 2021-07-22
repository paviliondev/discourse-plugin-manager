import Component from '@ember/component';
import { getOwner } from 'discourse-common/lib/get-owner';
import { default as discourseComputed } from 'discourse-common/utils/decorators';

export default Component.extend({
  classNameBindings: [':server-status', 'visible'],
  maximized: false,

  init() {
    this._super(...arguments);

    const container = getOwner(this);
    const controller = container.lookup('controller:application');
    const router = container.lookup("router:main");

    this.setProperties({
      router,
      discourse: controller.get('discourse'),
      plugins: controller.get('plugins')
    });
  },

  @discourseComputed('router.currentPath')
  visible(currentPath) {
    return currentPath && currentPath.indexOf('admin') === -1;
  },

  click(e) {
    if ($(e.target).closest('.top').length > 0) {
      this.toggleProperty('maximized');
    }
  },

  @discourseComputed('maximized')
  bottomClass(maximized) {
    return maximized ? 'maximized' : '';
  }
});