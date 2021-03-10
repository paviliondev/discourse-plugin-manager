##Discourse Plugin Manager Server

A plugin to protect a site from broken plugins.

###Dev scripts

These are useful because this plugin requires changes to the discourse install directly.  This would normally break plugin git code management workflows, so these scripts have been added:

* run `dev_setup.sh` in the Discourse dev root to put required files into Discourse directory
* run `dev_transfer.sh` to move altered files back to the plugin directory so that you can check changes into git
* run `dev_clean.sh` to remove all changes to the Discourse instance to rid it of the plugins alterations.

**Be careful to run these in a logical order, don't clean up before transferring your changes back to the plugin folder!**
