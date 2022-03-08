export default {
  resource: "admin",
  map() {
    this.route("adminPluginManager", {
      path: "/plugin-manager",
      resetNamespace: true,
    });
  },
};
