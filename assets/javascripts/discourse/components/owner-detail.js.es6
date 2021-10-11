import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from 'I18n';

export default Component.extend({
  classNames: 'owner-detail',

  @discourseComputed('owner.type')
  typeIcon(type) {
    return {
      user: 'user',
      organization: 'building'
    }[type];
  },

  @discourseComputed('owner.type')
  typeLabel(type) {
    return I18n.t(`server_status.plugin.owner.type.${type}`);;
  }
});