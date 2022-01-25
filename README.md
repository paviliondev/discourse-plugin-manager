## Discourse Plugin Manager

Discourse plugin manager running on ``stable.plugins.discourse.pavilion.tech`` and ``plugins.discourse.pavilion.tech`` ("the servers"). Should be run with ``paviliondev/discourse-plugin-guard``.

Note that this plugin manually overrides files in the Discourse installation itself, before any other plugin is loaded. This is to ensure all plugin errors are caught and handled by this plugin without affecting the normal operation of Discourse. As long as you follow the steps outlined below when developing and deploying the plugin everything will work as expected.

### Settings

The following settings are required for this plugin

- allow user api key scopes: ``discourse-plugin-manager:plugin_user``
- plugin manager github oauth client id
- plugin manager github oauth client secret

### Development

First, make sure you have ``paviliondev/discourse-plugin-guard`` installed. Then setup three environment variables

```
PLUGIN_MANAGER_ROOT: the root of paviliondev/discourse-plugin-manager
PLUGIN_GUARD_ROOT: the root of paviliondev/discourse-plugin-guard
DISCOURSE_ROOT: the root of discourse/discourse
```

Use a development workflow that looks like this

1. Run ``bin/setup.sh`` in both plugins to create the necessary folders and symlink the necessary files.

2. Perform development as normal.

3. When you've finished:

   - If you've added or removed files or folders in ``lib`` make sure ``bin/setup.sh`` and ``templates/plugin_guard.template.yml`` are updated accordingly.

   - Clean your ``discourse/discourse`` working tree.

### Deployment

Deploying updates of this plugin is slightly different from a deploying a normal plugin update. The script in ``bin/update.sh`` will handle it for you. It's present on the servers running this plugin in ``/usr/local/bin/update_discourse``. Just run ``update_discourse`` on the relevant server.

### Scheduled Rebuilds

The servers running this plugin use ``crontab`` to automatically rebuild every 24 hours, and automatically cleanup docker containers every Monday and Thursday. 

The cron jobs on both servers are

```
0 00 * * * /usr/local/bin/rebuild_discourse >>/tmp/cron_debug_log.log 2>&1
0 00 * * 1,4 /usr/local/bin/cleanup_discourse >>/tmp/cron_debug_log.log 2>&1
```

The templates for ``rebuild_discourse`` and ``cleanup_discourse`` are ``bin/rebuild.sh`` and ``bin/cleanup.sh``.

### External Monitoring

The 4 cron jobs on the 2 servers are monitored on cronitor.io. The [CronitorCLI](https://cronitor.io/docs/using-cronitor-cli) is installed on the servers, tracking the cron jobs mentioned above. That is why the actual jobs in ``crontab`` look like this:

```
0 00 * * * cronitor exec 4S7IAm ...
```

If a job does not start, or it fails to complete, then an alert is sent to angus@thepavilion.io [to be changed to dev@thepavilion.io, which will be setup as a group email on thepavilion.io].

