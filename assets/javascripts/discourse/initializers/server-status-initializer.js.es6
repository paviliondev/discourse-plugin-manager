import ApplicationRoute from 'discourse/routes/application';

export default {
  name: 'server-status',
  initialize() {
    ApplicationRoute.reopen({
      afterModel(model) {
        return ajax('/server-status').then(result => {
          console.log(result)
          this.controllerFor('application').set('serverStatus', result)
        })
      }
    })
  }
}