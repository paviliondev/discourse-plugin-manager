export default {
  resource: "admin",
  map() {
    this.route("adminPlugin", {
      path: "/plugin-manager",
      resetNamespace: true,
    });
  },
};
