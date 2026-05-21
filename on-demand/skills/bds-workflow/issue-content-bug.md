# Bug Issue Content Rules

Use `bug` when existing behavior is broken.

## Required Intake

Collect these fields before `bd create`:

- Observed behavior.
- Expected behavior.
- Evidence or reproduction signal.
- Affected scope.

## Description Template

Use these headings in the issue description.

### Observed Behavior

State what is happening now. Include the smallest concrete evidence available:
error text, command output summary, UI state, failing test, or reproduction
step.

### Expected Behavior

State the behavior that should happen instead.

### Affected Scope

Name the user path, command, file area, platform, or scenario known to be
affected. If the scope is uncertain, say what is known and what remains
unknown.

### Root Cause Status

Use `Unknown` unless the evidence uniquely confirms the root cause. If unknown,
state what information would resolve it. Do not write speculative fixes as
facts.

### Fix Boundary

Record only agreed constraints that would change execution. If a fix approach
has already been confirmed, state it at decision level. Low-level details belong
in comments or notes after they become true.

Add `#### Alternatives Considered` under this section only when concrete fix
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
