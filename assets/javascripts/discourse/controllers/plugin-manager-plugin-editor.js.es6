import Controller from "@ember/controller";
import discourseComputed, { bind } from "discourse-common/utils/decorators";
import Plugin from "../models/plugin";
import { alias, empty, equal, not, or } from "@ember/object/computed";
import ModalFunctionality from "discourse/mixins/modal-functionality";
import { schedule } from "@ember/runloop";

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
    this.set("model", null);
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
        name: model.name,
        authors: model.authors,
        about: model.about,
        contact_emails: model.contact_emails,
        test_host: model.test_host,
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
