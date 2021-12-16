## Discourse Plugin Manager Server

Discourse plugin management server running on ``stable.plugins.discourse.pavilion.tech`` and ``plugins.discourse.pavilion.tech``.

Note that this plugin manually overrides files in the Discourse installation itself, before any other plugin is loaded. This is to ensure all plugin errors are caught and handled by this plugin without affecting the normal operation of Discourse. As long as you follow the steps outlined below when developing and deploying the plugin everything will work as expected.

### Development

Setup two environment variables

```
PLUGIN_MANAGER_ROOT: the root of paviliondev/discourse-plugin-manager-server
DISCOURSE_ROOT: the root of discourse/discourse
```

Use a development workflow that looks like this

1. Run ``bin/setup.sh`` to create the necessary folders and symlink the necessary files.

2. Perform development as normal.

3. When you've finished:

   - If you've added or removed files or folders in ``lib`` make sure ``bin/setup.sh`` and ``templates/plugin_guard.template.yml`` are updated accordingly.

   - Clean your ``discourse/discourse`` working tree.

### Deployment

Deploying updates of this plugin is slightly different from a deploying a normal plugin update. The script in ``bin/update.sh`` will handle it for you. It's present on the servers running this plugin in ``/usr/local/bin/update_discourse``. Just run this command on the relevant server:

```
update_discourse
```

### Scheduled Rebuilds

The servers running this plugin use ``crontab`` to automatically rebuild every 24 hours, and automatically cleanup docker containers every week. 

The cron jobs on both servers are

```
0 00 * * * /usr/local/bin/rebuild_discourse >>/tmp/cron_debug_log.log 2>&1
0 00 * * 7 /usr/local/bin/cleanup_discourse >>/tmp/cron_debug_log.log 2>&1
```

The templates for ``rebuild_discourse`` and ``cleanup_discourse`` are ``bin/rebuild.sh`` and ``bin/cleanup.sh``.

