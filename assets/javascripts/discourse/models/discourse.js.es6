import EmberObject from "@ember/object";

const Discourse = EmberObject.extend({
  url: "https://github.com/discourse/discourse",
  branch: "tests-passed",
});

export default Discourse;
