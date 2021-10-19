## Discourse Plugin Manager Server

A plugin to protect a site from broken plugins.

This plugin requires files to be in place prior to any other Discourse code being run. This is achieved locally via bash scripts and in production via a web template.

### Development

These are useful because this plugin requires changes to the discourse install directly.  This would normally break plugin git code management workflows, so these scripts have been added:

* run `dev_setup.sh` in the Discourse dev root to put required files into Discourse directory
* run `dev_transfer.sh` to move altered files back to the plugin directory so that you can check changes into git
* run `dev_clean.sh` to remove all changes to the Discourse instance to rid it of the plugins alterations.

Note: they use a couple of ENV variables:

* $CODE_ROOT: the root of your code directory one level above each plugin
* $DISCOURSE_ROOT: the root of your development Discourse install

**Be careful to run these in a logical order, don't clean up before transferring your changes back to the plugin folder!**

### Deployment

Deploying updates to production is a two step process:

1. Go to ``/var/discourse/shared/standalone/discourse-plugin-manager-server`` and run ``git pull``. This instance of the repo needs to be on the same branch as the one you've set for the ``discourse-plugin-manager-server`` in the ``app.yml``.

   Why is this necessary? The pups template relies on the latest files being in place in the shared folder so it can copy them across before the other plugin code is pulled from GitHub.com

2. Rebuild the app as normal (i.e. from ``/var/discourse``)


