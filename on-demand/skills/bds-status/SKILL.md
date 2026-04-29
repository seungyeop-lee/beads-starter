---
name: bds-status
description: Summarize ready issues and current in-progress state. Runs only on explicit invocation.
---

# Beads Status

Quick overview of the current beads queue.

## On Activation

Run the queries below and present a concise summary.

### 1. Ready issues

```bash
bd ready
```

Show the list. If empty, say "No ready issues."

### 2. In-progress issues

Find issues currently `in_progress`. Try `bd list --status=in_progress` first; if that form is not supported by the installed bd version, fall back to whichever query the local `bd` exposes.

If more than one issue is `in_progress`, **flag this** — per the `bds-workflow` Concurrency rule, only one issue should be `in_progress` per session.

## Output Format

Keep it short:

```
Ready (N):
  ABC-12  Title here
  ABC-15  Another title

In progress (M):
  ABC-09  Currently being worked on
```

Do not call `bd show` for each issue — the user can ask separately if they want details.

## If bd Is Missing

If `bd` is not installed or `.beads/` does not exist, suggest `/bds-setup` and stop.
