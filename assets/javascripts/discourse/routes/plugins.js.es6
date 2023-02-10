import DiscourseRoute from "discourse/routes/discourse";
import Discourse from "../models/discourse";
import Plugin from "../models/plugin";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  queryParams: {
    branch: {
      refreshModel: true,
    },
  },

  model(params) {
    return Plugin.list({ branch: params.branch });
  },

  setupController(controller, model) {
    this._super(...arguments);

    const discourse = Discourse.create({ branch: model.branch });
    const plugins = A(model.plugins.map((plugin) => Plugin.create(plugin)));

    controller.setProperties({
      discourse,
      plugins,
    });
  },
});
