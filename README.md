# beads-starter

*English · [한국어](README.ko.md)*

> One-shot install script that injects a [beads](https://github.com/steveyegge/beads)
> workflow preset into an existing project repository.
>
> **Unofficial.** Not affiliated with the beads project.

## What it does

When run inside a target repository, it injects the following four things as
marker-delimited regions.

- `.gitignore` — excludes beads artifacts (`.beads/`, `.dolt/`, `*.db`) from
  source control
- `AGENTS.md` section — beads-based agent workflow (10-step flow from register
  through close, issue authoring rules, commit conventions, shell safety)
- `docs/beads-starter/bd-setup.md` — initial `bd init` setup guide (templated
  with the prefix you choose)
- `docs/beads-starter/beads-commands.md` — common `bd` command examples

All injected content is wrapped in `beads-starter` marker comments, so
re-running only refreshes the inside of those regions, and uninstalling leaves
content outside the markers untouched.

## Install

Run from the root of the target repository.

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/beads-starter.sh | bash -s -- install
```

Interactive mode prompts for the beads issue prefix (defaults to the current
directory name) and for confirmation before writing files.

### Non-interactive

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/beads-starter.sh | bash -s -- install --yes
```

Pins the prefix to the current directory name and runs without prompts.

## Update

After the starter's payload is updated upstream, sync the target repo to
latest:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/beads-starter.sh | bash -s -- update
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

## Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/beads-starter.sh | bash -s -- uninstall --yes
```

Removes every `beads-starter` marker region from the target repo. Files that
contained nothing but a marker region are left empty; remove them manually if
you want.

It does not touch artifacts that bd itself installed or created — the
`.beads/` directory, the `bd` CLI binary, `~/.beads/shared-server/`, etc.
After running, the script prints paths so you can clean those up yourself.

## Commands

- `install [--yes|-y]` — inject marker regions. `--yes` skips prompts.
- `update` — re-inject the inside of marker regions while preserving the
  existing prefix. Takes no flags; always non-interactive.
- `uninstall [--yes|-y]` — remove marker regions. `--yes` skips the
  confirmation prompt.
- `-h`, `--help` — print usage. `<command> --help` shows per-subcommand
  details.

## Operating mode

The preset configures beads in **shared-server** mode (local only, no Dolt
remote). The setup targets git worktree workflows and single-machine use. The
actual `bd init` command to run ships verbatim in the injected
`docs/beads-starter/bd-setup.md`.

## After installing

Ask your AI agent to follow `docs/beads-starter/bd-setup.md` to install and
initialize bd. That document covers the bd install check, `bd init`, and the
follow-up `bd config` calls in order.

## License

[MIT](LICENSE)
