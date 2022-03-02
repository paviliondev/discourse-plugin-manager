import Controller from "@ember/controller";
import discourseComputed, { bind } from "discourse-common/utils/decorators";
import Plugin from "../models/plugin";
import { alias, empty, equal, not, or } from "@ember/object/computed";
import ModalFunctionality from "discourse/mixins/modal-functionality";
import { schedule } from "@ember/runloop";

const pluginStatuses = {
  unknown: 0,
  compatible: 1,
  incompatible: 2,
};

export default Controller.extend(ModalFunctionality, {
  readOnlyStatus: equal("model.status", "tests_failing"),
  showPlugin: or("model.name", "retrieving"),
  canAdd: false,
  isNew: alias("model.new"),
  canRetrieve: alias("isNew"),
  urlDisabled: not("canRetrieve"),
  retrieveDisabled: empty("model.url"),
  discourseBranches: ["main", "tests-passed", "stable"],

  @discourseComputed("retrieved", "retrieving")
  addPluginDisabled(retrieved, retrieving) {
    return !retrieved || retrieving;
  },

  @discourseComputed
  pluginStatuses() {
    return Object.keys(pluginStatuses).map((status) => ({
      id: pluginStatuses[status],
      name: status,
    }));
  },

  @discourseComputed("isNew")
  modalTitle(isNew) {
    return `admin.plugin_manager.plugin.${isNew ? "add" : "edit"}`;
  },

  setupEvents() {
    schedule("afterRender", () => {
      const element = document.querySelector(".plugin-url");
      element.addEventListener("keydown", this.keyDown);
    });
  },

  onClose() {
    const element = document.querySelector(".plugin-url");
    element.removeEventListener("keydown", this.keyDown);
  },

  @bind
  keyDown(event) {
    if (event.key === "Enter" && this.canRetrieve && !this.retrieveDisabled) {
      this.send("retrieve");
    }
  },

  actions: {
    retrieve() {
      this.clearFlash();

      this.set("retrieving", true);
      const data = {
        url: this.model.url,
        branch: this.model.branch,
      };
      Plugin.retrieve(data).then((result) => {
        if (result.success) {
          this.setProperties({
            model: Plugin.create(result.plugin),
            retrieved: true,
          });
        } else {
          this.flash(result.error, "error");
        }
        this.set("retrieving", false);
      });
    },

    save() {
      this.set("saving", true);
      const model = this.model;
      const attrs = {
        url: model.url,
        support_url: model.support_url,
        try_url: model.try_url,
        name: model.name,
        authors: model.authors,
        about: model.about,
        version: model.version,
        contact_emails: model.contact_emails,
        test_host: model.test_host,
        status: model.status,
      };
      Plugin.save(attrs).then((result) => {
        if (result.success) {
          this.afterSave(Plugin.create(result.plugin));
        }
        this.set("saving", false);
        this.send("closeModal");
      });
    },
  },
});
