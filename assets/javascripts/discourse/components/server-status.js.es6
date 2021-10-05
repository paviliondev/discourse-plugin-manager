import Component from '@ember/component';
import { getOwner } from 'discourse-common/lib/get-owner';
import { default as discourseComputed } from 'discourse-common/utils/decorators';

const pluginStatuses = [
  'recommended',
  'compatible',
  'incompatible',
  'tests_failing'
];

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
      pluginLists: pluginStatuses.map(status => {
        return {
          status,
          plugins: plugins.filter(p => p.status === status)
        }
      })
    });
  },

  @discourseComputed('router.currentPath')
  visible(currentPath) {
    return currentPath && currentPath.indexOf('admin') === -1;
  }
});