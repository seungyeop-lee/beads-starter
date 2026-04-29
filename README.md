# beads-starter

*English · [한국어](README.ko.md)*

> Two ways to bring [beads](https://github.com/steveyegge/beads) workflow
> conventions into a project: an always-on bash installer, and an on-demand
> skill bundle for Claude Code or Codex CLI.
>
> **Unofficial.** Not affiliated with the beads project.

## Choose a mode

| | Always-on mode | On-demand mode |
|---|---|---|
| Mechanism | Bash installer injects content into target repo files | Three skills loaded only on explicit invocation |
| When the workflow applies | Every session, automatically | Only when you explicitly invoke the `bds-workflow` skill |
| Distribution | `curl | bash` | Claude Code plugin marketplace, or `curl | bash` (Codex) |
| Agent compatibility | Any agent that reads `AGENTS.md` (Claude Code, Cursor, Codex, …) | Claude Code, Codex CLI |
| Pick this if | You want the workflow to apply to every task without thinking about it, or you use multiple AI agents | You want to opt in per task |

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

## On-demand mode (Claude Code or Codex)

Three skills that expose beads workflow conventions, loaded only when you
explicitly invoke them. The repo's working files are not modified; everything
lives where the host tool stores skills.

### Skills

- `bds-workflow` — load the 10-step workflow rules (register → close), with
  on-demand references to issue-content rules, shell-safety, commit rules, and
  command examples.
- `bds-setup` — install bd if missing and initialize the project (`bd init`
  with this preset's flags). Hybrid flow: prints each command and asks before
  running.
- `bds-status` — summarize ready issues and current in-progress state.

All three only run when you invoke them explicitly. None auto-activate based
on session content.

### Claude Code

Add this repository as a Claude Code plugin marketplace, then install the
`beads-starter` plugin from it. (Refer to your Claude Code version's docs for
the exact marketplace add/install flow.)

Invoke with slash commands: `/bds-workflow`, `/bds-setup`, `/bds-status`.

### Codex CLI

A bash installer copies the three skills into Codex's skill directory. No
Codex plugin manifest is required — Codex auto-discovers `SKILL.md` files in
its skill directories.

#### Install

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

#### Update

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- update --scope=user --yes
```

Replaces the three skill directories with the latest content. Errors out if
no beads-starter skill is found in the chosen scope.

#### Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- uninstall --scope=user --yes
```

Removes only `bds-workflow/`, `bds-setup/`, `bds-status/` from the chosen
scope. Other skills under the same parent directory are untouched.

### Initialize a repository

In a repo that hasn't used bd yet, invoke the `bds-setup` skill:

- Claude Code: `/bds-setup`
- Codex CLI: `/skills` and pick `bds-setup`, or mention `$bds-setup`

It walks you through bd install (if missing), prefix selection, and the four
init/config commands.

### Use the workflow

At the start of a beads-related task, invoke the `bds-workflow` skill. It
loads the 10-step workflow rules and stays in context for the rest of the
session. Check queue state any time with `bds-status`.

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
