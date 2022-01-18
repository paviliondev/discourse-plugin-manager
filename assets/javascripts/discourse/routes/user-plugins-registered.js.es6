import Route from "@ember/routing/route";
import UserPlugin from "../models/user-plugin";

export default Route.extend({
  model() {
    const user = this.modelFor("user");
    return UserPlugin.registered(user.username);
  },
});
