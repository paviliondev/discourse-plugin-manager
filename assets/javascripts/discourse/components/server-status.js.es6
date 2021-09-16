import Component from '@ember/component';
import { getOwner } from 'discourse-common/lib/get-owner';
import { default as discourseComputed } from 'discourse-common/utils/decorators';

export default Component.extend({
  classNameBindings: [':server-status', 'visible'],

  init() {
    this._super(...arguments);

    const container = getOwner(this);
    const controller = container.lookup('controller:application');
    const router = container.lookup("router:main");
    const plugins = controller.get('plugins');
    const discourse = controller.get('discourse');

    this.setProperties({
      router,
      discourse,
      recommendedPlugins: plugins.filter(p => p.status === 'recommended'),
      compatiblePlugins: plugins.filter(p => p.status === 'compatible'),
      incompatiblePlugins: plugins.filter(p => p.status === 'incompatible'),
      testsFailingPlugins: plugins.filter(p => p.status === 'tests_failing')
    });
  },

  @discourseComputed('router.currentPath')
  visible(currentPath) {
    return currentPath && currentPath.indexOf('admin') === -1;
  }
});