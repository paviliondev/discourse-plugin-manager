export default {
  resource: "user",
  path: "users/:username",
  map() {
    this.route("plugins", function () {
      this.route("registered");
    });
  },
};
