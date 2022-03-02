import Component from "@ember/component";

export default Component.extend({
  classNames: ["discourse-status"],
  branches: ["main", "stable"].map((b) => ({ id: b, name: b })),
});
