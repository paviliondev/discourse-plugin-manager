import { underscore } from "@ember/string";
import Component from '@ember/component';
import { default as discourseComputed } from 'discourse-common/utils/decorators';
import I18n from "I18n";

export default Component.extend({
  classNameBindings: [':plugin-statuses', 'type'],
  
  @discourseComputed('type')
  header(type) {
    return I18n.t(`discourse_server_status.${underscore(type)}.header`);
  },
  
  @discourseComputed('type')
  description(type) {
    return I18n.t(`discourse_server_status.${underscore(type)}.description`, {
      discourseVersion: this.discourse.installed_version
    });
  }
})