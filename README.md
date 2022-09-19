## Discourse Plugin Manager

Discourse plugin manager running on ``discourse.pluginmanager.org``.

Note that this plugin manually overrides files in the Discourse installation itself, before any other plugin is loaded. As long as you follow the steps outlined below when developing and deploying the plugin everything will work as expected.

### Settings

The following settings are required for this plugin

- allow user api key scopes: ``discourse-plugin-manager:plugin_user``
- plugin manager github oauth client id
- plugin manager github oauth client secret

### Development

Setup these environment variables

```
PLUGIN_MANAGER_ROOT: the root of paviliondev/discourse-plugin-manager
DISCOURSE_ROOT: the root of discourse/discourse
```

Use a development workflow that looks like this

1. Run ``bin/setup.sh`` to create the necessary folders and symlink the necessary files.

2. Perform development as normal.

3. When you've finished:

   - If you've added or removed files or folders in ``lib`` make sure ``bin/setup.sh`` and ``templates/plugin_manager.template.yml`` are updated accordingly.

   - Clean your ``discourse/discourse`` working tree.

### Deployment

Deploying updates of this plugin is slightly different from a deploying a normal plugin update. The script in ``bin/update.sh`` will handle it for you. It's present on `discourse.pluginmanager.org` in ``/usr/local/bin/discourse_update``. Just run ``discourse_update`` on the server.
