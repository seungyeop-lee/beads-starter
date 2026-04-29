# On-demand mode (Claude Code or Codex)

*English · [한국어](README.ko.md)*

Three skills that expose beads workflow conventions, loaded only when you
explicitly invoke them. The repo's working files are not modified; everything
lives where the host tool stores skills.

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
/plugin install beads-starter@seungyeop-lee/beads-starter
```

After installation, run `/reload-plugins` to activate the plugin without
restarting Claude Code. The install command prompts for scope (User, Project,
or Local) interactively.

Invoke with slash commands: `/bds-workflow`, `/bds-setup`, `/bds-status`.

## Codex CLI

A bash installer copies the three skills into Codex's skill directory. No
Codex plugin manifest is required — Codex auto-discovers `SKILL.md` files in
its skill directories.

### Install

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- install
```

Interactive mode prompts for the scope:

- `user` — `~/.codex/skills/bds-*/` (machine-wide; honors `$CODEX_HOME` if set)
- `project` — `<cwd>/.agents/skills/bds-*/` (current repo only; check it into
  version control to share with collaborators)

Non-interactive variants:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- install --scope=user --yes
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- install --scope=project --yes
```

If Codex CLI is currently running, restart it so the new skills are picked
up. Invoke from inside Codex via `/skills` or by mentioning `$bds-workflow`;
see the [Codex skills docs](https://developers.openai.com/codex/skills) for
the exact UI.

### Update

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- update --scope=user --yes
```

Replaces the three skill directories with the latest content. Errors out if
no beads-starter skill is found in the chosen scope.

### Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- uninstall --scope=user --yes
```

Removes only `bds-workflow/`, `bds-setup/`, `bds-status/` from the chosen
scope. Other skills under the same parent directory are untouched.

## Initialize a repository

In a repo that hasn't used bd yet, invoke the `bds-setup` skill:

- Claude Code: `/bds-setup`
- Codex CLI: `/skills` and pick `bds-setup`, or mention `$bds-setup`

It walks you through bd install (if missing), prefix selection, and the four
init/config commands.

## Use the workflow

At the start of a beads-related task, invoke the `bds-workflow` skill. It
loads the 10-step workflow rules and stays in context for the rest of the
session. Check queue state any time with `bds-status`.
