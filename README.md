## Discourse Plugin Manager Server

Discourse plugin management server running on ``stable.plugins.discourse.pavilion.tech`` and ``plugins.discourse.pavilion.tech``.

This customisation requires files be placed and overridden in the Discourse installation itself.  This is necessary because this customisation overrides some of the plugin management systems within Discourse.

### Development

Setup two environment variables

```
PLUGIN_MANAGER_ROOT: the root of paviliondev/discourse-plugin-manager-server
DISCOURSE_ROOT: the root of discourse/discourse
```

Use a development workflow that looks like this

1. Run ``bin/setup.sh`` from your Discourse root to create the necessary folders and symlink the necessary files.

2. Perform development as normal

3. When you've finished:

   - if you've added or removed files or folders in ``lib`` make sure ``bin/setup.sh`` is updated accordingly; and
   
   - clean your ``discourse/discourse`` working tree.

### Deployment

Deploying updates to production is a two step process:

1. Go to ``/var/discourse/shared/standalone/discourse-plugin-manager-server`` and run ``git pull``. This instance of the repo needs to be on the same branch as the one you've set for the ``discourse-plugin-manager-server`` in the ``app.yml``.

   Why is this necessary? The pups template relies on the latest files being in place in the shared folder so it can copy them across before the other plugin code is pulled from GitHub.com

2. Rebuild the app as normal (running ``/launcher rebuild app`` from ``/var/discourse``)

### Scheduled rebuilds

The servers running this plugin use ``crontab`` to automatically rebuild every 24 hours. The ``cron`` command is

```
0 00 * * * /usr/local/bin/rebuild_discourse >>/tmp/cron_debug_log.log 2>&1
```

The contents of ``/usr/local/bin/rebuild_discourse`` is

```

