import Component from "@ember/component";

export default Component.extend({
  classNames: ["discourse-status"],
  branches: ["tests-passed", "stable"].map((b) => ({ id: b, name: b })),
});
