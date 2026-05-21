# Task Issue Content Rules

Use `task` for a concrete work item that changes implementation, tests, docs,
or structure and is not better described as a bug, feature, chore, or grouping
issue.

## Required Intake

Collect these fields before `bd create`:

- Target change.
- Agreed approach or constraints.
- Acceptance or verification criteria.

## Description Template

Use these headings in the issue description.

### Target Change

State the concrete outcome this task must produce.

### Approach

Record the currently agreed approach at decision level: chosen direction, known
constraints, and scope boundaries that would change execution. Low-level
implementation detail belongs in comments or notes after it becomes true.

Add `#### Alternatives Considered` under this section only when concrete
approaches were actually compared, the user rejected one approach and directed
another, or execution feedback changed the recorded decision.

### Verification

List practical checks known at creation time. Step 5 of the workflow executes
every item, so each item must be unambiguous.

### Out of Scope

Include this section only when the boundary is non-trivial.

## Parent Close Handling

When this issue is created under a parent (via `--parent=<parent-id>` or
`bd dep add <child-id> <parent-id> --type=parent-child`), include the heading
below as the last section of the description, replacing `<PARENT-ID>` with
the actual parent ID.

### Parent Close Check

Parent: `<PARENT-ID>`.

After running `bd close` on this issue at step 10, query sibling statuses
(`bd show <PARENT-ID>`, or `bd epic status <PARENT-ID>` for an `epic`
parent). If every sibling — including this issue — is `closed`, evaluate the
parent's Completion Criteria. If satisfied, run `bd close <PARENT-ID>` with
reason `Cascade: all children closed; Completion Criteria met
(child: <THIS-ID>)`. If the parent itself has a parent, repeat upward.
