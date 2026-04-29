# Beads Command Examples

`bd` command examples for common workflows.

## Agent Workflow CLI Forms

- create: `bd create ... --silent` (ID only; step 1 and mid-execution discovery)
- create under parent: `bd create ... --parent=<parent-id> --silent`
- link existing child: `bd dep add <child-id> <parent-id> --type=parent-child`
- in_progress: `bd update <id> --status=in_progress`
- comment: `bd comments add <id> "<text>"` (positional text, **not** `--message`)
- notes: `bd update <id> --notes="..."`
- close: `bd close <id> --reason="..."`
- read comments: `bd comments <id>` (post-step 8; lighter than `bd show`)
- scan titles: `bd show <id> --short` or `bd ready`

## Starting Work

```
bd ready                              # List unblocked issues
bd show <id>                          # Review issue details
# After user says "approved":
bd update <id> --status=in_progress   # Transition before touching any file
```

## Completing Work

```
# 1. Stage only files belonging to this issue
git add <file1> <file2>

# 2. Commit
git commit -m "feat(scope): ..."

# 3. Record commit on the issue
bd comments add <id> "commit: $(git rev-parse --short HEAD) feat(scope): ..."

# 4. Notes — only for durable context not already in diff/commit/comment
bd update <id> --notes="..."

# 5. Close
bd close <id>
```

## Mid-Execution Discovery

Do not interrupt the current issue. Create a new issue and link it with a `discovered-from` dependency:

```
bd create --title="Newly discovered work" --description="..." --type=task
bd dep add <new-id> <current-id>      # new-id depends on current-id
```

Then continue working on the current issue.

## Creating Epics

`bd epic status` only recognizes an epic when **children depend on the epic** (not the other way around). Adding the dependency as `epic → child` causes `bd epic status` to return an empty list.

Do not create hierarchy by default. For directly executable work, create a single `task`, `bug`, or `chore`. When work needs grouping, prefer `epic -> feature -> executable issue`, where executable issue means `task`, `bug`, or `chore`.

```
# 1. Create the epic
bd create --title="Epic title" --description="..." --type=epic

# 2. Create features under the epic
bd create --title="Feature A" --description="..." --type=feature --parent=<epic-id>
bd create --title="Feature B" --description="..." --type=feature --parent=<epic-id>

# 3. Create executable issues under a feature
bd create --title="Task A" --description="..." --type=task --parent=<feature-id>
bd create --title="Bug A" --description="..." --type=bug --parent=<feature-id>
bd create --title="Chore A" --description="..." --type=chore --parent=<feature-id>
```

Use `bd dep add` to link existing issues:

```
bd dep add <feature-id> <epic-id> --type=parent-child
bd dep add <executable-issue-id> <feature-id> --type=parent-child
```

Avoid attaching executable issues directly under an epic unless no meaningful feature grouping exists.

**Direction rule:** `bd dep add A B` means "A depends on B", so `A` is the child and `B` is the parent.

## Lifecycle Commands

Adjunct commands outside the main 10-step flow.

- `bd defer <id>` — park an issue without closing it.
- `bd supersede <id>` — mark an issue as replaced by another.
- `bd stale` — surface issues that have gone quiet.
- `bd orphans` — surface issues missing expected dependency links.
- `bd lint` — check issue hygiene.
- `bd human <id>` — flag an issue as requiring a human decision.
- `bd formula list` / `bd mol pour <name>` — structured workflow templates.
