# beads-starter

*English · [한국어](README.ko.md)*

> Two ways to bring [beads](https://github.com/steveyegge/beads) workflow
> conventions into a project: an always-on bash installer and an on-demand
> Claude Code plugin.
>
> **Unofficial.** Not affiliated with the beads project.

## Choose a mode

| | Always-on mode | On-demand mode |
|---|---|---|
| Mechanism | Bash installer injects content into target repo files | Claude Code plugin loaded via slash commands |
| When the workflow applies | Every session, automatically | Only when you explicitly invoke `/bds-workflow` |
| Distribution | `curl | bash` | Claude Code plugin marketplace |
| Agent compatibility | Any agent that reads `AGENTS.md` (Claude Code, Cursor, Codex, …) | Claude Code only |
| Pick this if | You want the workflow to apply to every task without thinking about it, or you use multiple AI agents | You use Claude Code only and want to opt in per task |

The two modes are mutually exclusive — pick one. If both are installed in the
same repo, the workflow rules will be loaded twice.

---

## Always-on mode (bash installer)

A one-shot bash installer that injects beads workflow conventions into target
repo files (`.gitignore`, `AGENTS.md`, `docs/beads-starter/*`). Once installed,
agents that read `AGENTS.md` see the workflow on every session.

### What it injects

- `.gitignore` — excludes beads artifacts (`.beads/`, `.dolt/`, `*.db`)
- `AGENTS.md` section — beads-based agent workflow (10-step flow, issue
  authoring rules, commit conventions, shell safety)
- `docs/beads-starter/bd-setup.md` — initial `bd init` setup guide (templated
  with the prefix you choose)
- `docs/beads-starter/beads-commands.md` — common `bd` command examples

All injected content is wrapped in `beads-starter` marker comments, so
re-running only refreshes the inside of those regions, and uninstalling leaves
content outside the markers untouched.

### Install

Run from the root of the target repository.

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- install
```

Interactive mode prompts for the beads issue prefix (defaults to the current
directory name) and for confirmation before writing files.

#### Non-interactive

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- install --yes
```

Pins the prefix to the current directory name and runs without prompts.

### Update

After the starter's payload is updated upstream, sync the target repo to
latest:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- update
```

- Only the **inside** of marker regions is replaced with the current `main`
  content. Content outside the markers is preserved.
- The prefix is auto-extracted from the existing
  `docs/beads-starter/bd-setup.md` marker region, so installations using a
  non-default prefix are safe. This command is non-interactive.
- Exits with an error if no marker region exists (i.e. not installed) or if
  prefix extraction fails.
- If new injection targets have been added, the corresponding files are
  created.
- If an injection target has been removed (rare), the old file is not cleaned
  up — delete it manually, or reset via `uninstall` followed by `install`.

### Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- uninstall --yes
```

Removes every `beads-starter` marker region from the target repo. Files that
contained nothing but a marker region are left empty; remove them manually if
you want.

It does not touch artifacts that bd itself installed or created — the
`.beads/` directory, the `bd` CLI binary, `~/.beads/shared-server/`, etc.
After running, the script prints paths so you can clean those up yourself.

### Commands

- `install [--yes|-y]` — inject marker regions. `--yes` skips prompts.
- `update` — re-inject the inside of marker regions while preserving the
  existing prefix. Takes no flags; always non-interactive.
- `uninstall [--yes|-y]` — remove marker regions. `--yes` skips the
  confirmation prompt.
- `-h`, `--help` — print usage. `<command> --help` shows per-subcommand
  details.

### Legacy URL

The pre-restructure URL
(`…/main/beads-starter.sh`, without the `always-on/` segment) still works as a
thin redirect to the new location and prints a deprecation notice on stderr.
Update any pinned references at your convenience.

---

## On-demand mode (Claude Code plugin)

A Claude Code plugin that exposes beads workflow conventions as three skills,
loaded only when you explicitly invoke them. The repo's working files are not
modified; everything lives in the plugin install.

### Skills

- `/bds-workflow` — load the 10-step workflow rules (register → close), with
  on-demand references to issue-content rules, shell-safety, commit rules, and
  command examples.
- `/bds-setup` — install bd if missing and initialize the project (`bd init`
  with this preset's flags). Hybrid flow: prints each command and asks before
  running.
- `/bds-status` — summarize ready issues and current in-progress state.

All three skills only run when you invoke them by slash command. None
auto-activate based on session content.

### Install

Add this repository as a Claude Code plugin marketplace, then install the
`beads-starter` plugin from it. (Refer to your Claude Code version's docs for
the exact marketplace add/install flow.)

### Initialize a repository

In a repo that hasn't used bd yet:

```
/bds-setup
```

Walks you through bd install (if missing), prefix selection, and the four
init/config commands.

### Use the workflow

At the start of a beads-related task in a Claude Code session:

```
/bds-workflow
```

Loads the 10-step workflow rules. Stays in context for the rest of the
session.

To check queue state at any time:

```
/bds-status
```

### Switching from always-on mode

If a repo already has the always-on injection (`AGENTS.md` and
`docs/beads-starter/*` markers), run the always-on uninstall first to avoid
double-loading the workflow rules:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- uninstall --yes
```

---

## Operating mode

Both modes configure beads in **shared-server** mode (local only, no Dolt
remote). The setup targets git worktree workflows and single-machine use.
The actual `bd init` command ships verbatim either in the injected
`docs/beads-starter/bd-setup.md` (always-on) or in the `bds-setup` skill
(on-demand).

## License

[MIT](LICENSE)
