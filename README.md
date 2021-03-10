## Discourse Plugin Manager Server

A plugin to protect a site from broken plugins.

Unusually it requires various files be placed and overriden in the Discourse installation itself.  This is necessary because the plugin overrides some of the plugin management systems within Discourse.

In Production this is taken care of by custom templates.

In Development, manual copying would be required, so a few scripts were developed to assist with this task.

### Dev scripts

These are useful because this plugin requires changes to the discourse install directly.  This would normally break plugin git code management workflows, so these scripts have been added:

* run `dev_setup.sh` in the Discourse dev root to put required files into Discourse directory
* run `dev_transfer.sh` to move altered files back to the plugin directory so that you can check changes into git
* run `dev_clean.sh` to remove all changes to the Discourse instance to rid it of the plugins alterations.

NB: they use a couple of ENV variables:

* $CODE_ROOT: the root of your code directory one level above each plugin
* $DISCOURSE_ROOT: the root of your development Discourse install

**Be careful to run these in a logical order, don't clean up before transferring your changes back to the plugin folder!**
