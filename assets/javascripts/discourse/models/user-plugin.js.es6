import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const UserPlugin = EmberObject.extend();

UserPlugin.reopenClass({
  registered(username) {
    return ajax(`/users/${username}/plugins/registered`).catch(popupAjaxError);
  },
});

export default UserPlugin;
