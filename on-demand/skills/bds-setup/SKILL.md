---
name: bds-setup
description: Install bd and initialize the project for beads-starter workflow. Runs only on explicit invocation.
---

# Beads Setup

One-time per-repository setup for the beads-starter workflow.

## On Activation

Walk the user through the steps below. For each command, **show the command first, then ask "Run this?"** before executing. Do not chain commands silently.

## Steps

### 1. Check for bd

Show:

```bash
command -v bd && bd version
```

If `bd` is already installed and reports a version, skip to step 3. Otherwise proceed to step 2.

### 2. Install bd (if missing)

The beads team recommends Homebrew. Show the user the options and ask which they want:

**Homebrew (macOS / Linux, recommended)**

```bash
brew install beads
```

**npm (Node.js users)**

```bash
npm install -g @beads/bd
```

**Install script (other platforms)**

```bash
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
```

For Windows, Arch AUR, `go install`, or building from source, point them to <https://github.com/steveyegge/beads/blob/main/docs/INSTALLING.md>.

### 3. Determine the prefix

The prefix is used for issue IDs (e.g., `MYPROJ-42`). Default suggestion: the current directory's basename. Confirm with the user before proceeding.

### 4. Initialize

Show all four commands together, then ask "Run all four?":

```bash
bd init --shared-server --prefix <PREFIX> --skip-agents --skip-hooks
bd config set no-git-ops true
bd config set export.git-add false
bd config unset sync.remote
```

Substitute `<PREFIX>` with the value from step 3.

### 5. Verify

Show:

```bash
bd ready --json
```

Run it after confirmation. A successful exit (even with empty JSON output) means setup is complete.

### 6. Brief the user on expected warnings

After setup, the following warnings are normal under this preset and should not trigger action:

From `bd init`:

- `Server host defaulted to 127.0.0.1` — correct for single-machine use.
- `Setup incomplete. No dolt database found` — clears on the next `bd` command.

From `bd doctor`:

- `Git Hooks: No recommended git hooks installed` — intentional (`--skip-hooks`).
- `Phantom Databases: beads_global` — cosmetic, see beads GH#2051.
- `Dolt Status` / `Dolt Locks: Uncommitted changes` — pending `bd config` writes auto-commit on the next `bd` command.
- `Git Working Tree: Uncommitted changes` — files outside `.beads/`. Commit them separately from bd work.
- `Claude Plugin: beads plugin not installed` / `Claude Integration: Not configured` — not part of this preset.

### 7. Warn against `bd doctor --fix`

`bd init` may suggest `bd doctor --fix`. Tell the user **not to run it** under this preset — it can re-apply changes the preset intentionally skipped (e.g., installing git hooks). Interpret warnings individually against the list above; anything outside that list should be surfaced for human review, not auto-fixed.

## Flag Notes (for the user's reference)

- `--shared-server` — use the shared Dolt server at `~/.beads/shared-server/`; all bd projects on this machine share one server process.
- `--prefix <PREFIX>` — issues are named `<PREFIX>-<id>`.
- `--skip-agents` — do not regenerate `AGENTS.md` (this plugin owns workflow content via the `bds-workflow` skill).
- `--skip-hooks` — do not install bd's git hooks.
- `no-git-ops: true` — suppress bd's automatic Dolt push.
- `export.git-add: false` — suppress automatic `git add` of `.beads/issues.jsonl`.
- `unset sync.remote` — remove the default Dolt remote URL set by `bd init`.

## After Setup

Tell the user:

- The full workflow is available via `/bds-workflow`.
- Current queue status via `/bds-status`.
