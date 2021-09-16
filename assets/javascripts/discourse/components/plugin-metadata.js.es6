import Component from "@ember/component";
import { notEmpty } from "@ember/object/computed";
import { default as discourseComputed } from 'discourse-common/utils/decorators';

export default Component.extend({
  tagName: 'ul',
  classNames: 'plugin-metadata',
  hasContactEmails: notEmpty('contactEmails'),

  @discourseComputed('plugin.contact_emails')
  contactEmails(emails) {
    return emails ? emails.split(',') : [];
  }
});