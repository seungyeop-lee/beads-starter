# Chore Issue Content Rules

Use `chore` for maintenance, operational upkeep, documentation/reference
artifacts, release preparation, cleanup, or tooling upkeep.

Do not subdivide `chore` into fixed subtypes such as docs, release, or cleanup.
Describe the concrete artifact or operation and the criteria that make it
complete.

## Required Intake

Collect these fields before `bd create`:

- Artifact or operation.
- Purpose.
- Consumer or audience.
- Acceptance criteria.

## Description Template

Use these headings in the issue description.

### Artifact or Operation

State the document, reference artifact, maintenance action, release preparation,
cleanup, or tooling upkeep this chore must produce.

### Purpose

State why the chore exists and what decision, workflow, or maintenance need it
serves.

### Consumer or Audience

State who or what will use the result: humans, agents, release operators,
maintainers, CI, local tooling, or another workflow.

### Constraints

Record only agreed constraints that would change execution: source material,
format, files to avoid, compatibility requirements, or operational boundaries.

Add `#### Alternatives Considered` under this section only when concrete
approaches were actually compared, the user rejected one approach and directed
another, or execution feedback changed the recorded decision.

### Acceptance Criteria

List practical criteria known at creation time. For document/reference chores,
criteria should describe what the artifact must let the consumer understand or
do, not just that a file exists.

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
