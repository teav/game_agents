# game-dev-marketplace

A Claude Code plugin marketplace for multi-agent development workflows. Currently hosts one plugin:

| Plugin           | Description                                                              |
| ---------------- | ------------------------------------------------------------------------ |
| `game-dev-team`  | 17-agent team for game development concept → MVP, with platform portability |

Future plugins (e.g., `web-dev-team`, `mobile-app-team`) will share this install root.

## Install the marketplace

```
/plugin marketplace add /path/to/game-dev-marketplace
# or, once pushed to git:
/plugin marketplace add https://github.com/<you>/game-dev-marketplace
```

## Install a plugin from it

```
/plugin install game-dev-team@game-dev-marketplace
```

Restart your Claude Code session after install, then see the plugin's own README for usage.

## Architecture: why a marketplace, not just a plugin

Marketplace and plugin sources are independent. The catalog at `.claude-plugin/marketplace.json` can reference plugins by relative path (local development), by full git URL (external repo), or pinned to a specific branch or commit. This lets you:

- Evolve plugins independently (each in its own version cadence)
- Pin specific versions per consumer
- Add new plugins later without changing how users install existing ones

For example, when you add `web-dev-team`, users who already installed `game-dev-team` only need to run `/plugin install web-dev-team@game-dev-marketplace` — they keep their existing install and tooling.

## Adding a new plugin to this marketplace

1. Create the plugin directory at the marketplace root (sibling of `game-dev-team/`).
2. Add a `.claude-plugin/plugin.json` inside it.
3. Append an entry to the `plugins` array in `.claude-plugin/marketplace.json`.
4. Push, then users run `/plugin marketplace update`.

## Validation

Validate the marketplace and all plugin manifests:

```bash
npx -y claude-code plugin validate
```

Or use the unofficial JSON schema for editor tooling:
- `https://json.schemastore.org/claude-code-marketplace.json`
- `https://json.schemastore.org/claude-code-plugin-manifest.json`

## License

MIT.
