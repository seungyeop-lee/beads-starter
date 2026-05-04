# On-demand mode (Claude Code or Codex)

*English · [한국어](README.ko.md)*

Three skills that expose beads workflow conventions, loaded only when you
explicitly invoke them. The repo's working files are not modified; everything
lives where the host tool stores plugin skills.

## Skills

- `bds-workflow` — load the 10-step workflow rules (register → close), with
  on-demand references to issue-content rules, shell-safety, commit rules, and
  command examples.
- `bds-setup` — install bd if missing and initialize the project (`bd init`
  with this preset's flags). Hybrid flow: prints each command and asks before
  running.
- `bds-status` — summarize ready issues and current in-progress state.

All three only run when you invoke them explicitly. None auto-activate based
on session content.

## Claude Code

Add this repository as a Claude Code plugin marketplace, then install the
`beads-starter` plugin from it.

```
/plugin marketplace add seungyeop-lee/beads-starter
/plugin install beads-starter@beads-starter
```

After installation, run `/reload-plugins` to activate the plugin without
restarting Claude Code. The install command prompts for scope (User, Project,
or Local) interactively.

Invoke with slash commands: `/bds-workflow`, `/bds-setup`, `/bds-status`.

## Codex

Add this repository as a Codex plugin marketplace, then install the
`beads-starter` plugin from Codex's plugin directory.

### Install

```bash
codex plugin marketplace add seungyeop-lee/beads-starter
```

After adding the marketplace, open Codex and run `/plugins`. Choose the
`beads-starter` marketplace, open the `beads-starter` plugin, and install it.

Invoke from inside Codex via `/skills` or by mentioning `$bds-workflow`; see
the [Codex plugin docs](https://developers.openai.com/codex/plugins) and
[Codex skills docs](https://developers.openai.com/codex/skills) for the exact
UI.

### Update

```bash
codex plugin marketplace upgrade beads-starter
```

Then open `/plugins` and update or reinstall the plugin if Codex shows a newer
version.

### Uninstall

Use `/plugins` in Codex and uninstall the `beads-starter` plugin.

### Legacy direct-skill cleanup

Older versions of this project used a bash installer that copied
`bds-workflow/`, `bds-setup/`, and `bds-status/` directly into Codex skill
directories. New installs should use the plugin path above. Use this cleanup
script only to remove those legacy direct-skill copies:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- uninstall --scope=user --yes
```

Scopes:

- `user` — `~/.codex/skills/bds-*/` (machine-wide; honors `$CODEX_HOME` if set)
- `project` — `<cwd>/.agents/skills/bds-*/` (current repo only)

The cleanup script removes only `bds-workflow/`, `bds-setup/`, and
`bds-status/` from the chosen scope. Other skills under the same parent
directory are untouched. Its old `install` and `update` commands now print the
Codex plugin install instructions and exit.

## Initialize a repository

In a repo that hasn't used bd yet, invoke the `bds-setup` skill:

- Claude Code: `/bds-setup`
- Codex: `/skills` and pick `bds-setup`, or mention `$bds-setup`

It walks you through bd install (if missing), prefix selection, and the four
init/config commands.

## Use the workflow

At the start of a beads-related task, invoke the `bds-workflow` skill. It
loads the 10-step workflow rules and stays in context for the rest of the
session. Check queue state any time with `bds-status`.
