# Feature Issue Content Rules

Use `feature` for new functionality or capability. Before writing the issue,
decide whether the feature is executable or grouping-oriented.

## Feature Mode Selection

An executable feature has one independently reviewable deliverable and direct
acceptance criteria.

A grouping feature is a parent issue for several executable issues. It closes
when its child issues satisfy the feature-level completion criteria.

Do not mix executable instructions and child-issue grouping in one feature. If
both are needed, create a grouping feature and separate executable child issues.

## Executable Feature Intake

Collect these fields before `bd create`:

- Capability.
- User or workflow impact.
- Approach or constraints.
- Acceptance criteria.

## Executable Feature Template

Use these headings when the feature itself is executable.

### Capability

State the new functionality or capability being added.

### User or Workflow Impact

State who or what workflow benefits, and what changes after the feature exists.

### Approach

Record the currently agreed approach at decision level: chosen direction, known
constraints, and scope boundaries that would change execution. Low-level
implementation detail belongs in comments or notes after it becomes true.

Add `#### Alternatives Considered` under this section only when concrete
approaches were actually compared, the user rejected one approach and directed
another, or execution feedback changed the recorded decision.

### Acceptance Criteria

List practical criteria known at creation time. Step 5 of the workflow executes
every checkable item, so each item must be unambiguous.

### Out of Scope

Include this section only when the boundary is non-trivial.

## Grouping Feature Intake

Collect these fields before `bd create`:

- Goal.
- Child issue criteria.
- Included work.
- Completion criteria.

## Grouping Feature Template

Use these headings when the feature groups child issues.

### Goal

State the feature-level outcome that the child issues collectively deliver.

### Child Issue Criteria

State what belongs under this feature and what should be a separate feature,
epic, or standalone issue.

### Included Work

List the known child work areas or child issue titles. If child issues already
exist, link them after creation with `bd dep add`.

### Completion Criteria

State how to know the grouped feature is complete.

### Non-goals

Include this section only when the boundary is non-trivial.

## Parent Close Handling

Applies to both executable and grouping feature modes.

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
