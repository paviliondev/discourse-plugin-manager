import Component from '@ember/component';

export default Component.extend({
  init() {
    this._super(...arguments);
    const controller = getOwner(this).lookup('controller:application');
    this.set('serverStatus', controller.get('serverStatus'));
  }
});