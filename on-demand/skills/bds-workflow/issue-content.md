# Issue Content Rules

How to write beads issue descriptions for this project.

## Lean Initial Descriptions

Initial descriptions should be intentionally lean. Record the minimum self-contained contract needed to start work; do not pre-fill implementation detail, speculative alternatives, or discoveries that have not happened yet.

## WHAT and METHOD

Every description must expose both **WHAT** and **METHOD** under clear headings (e.g., `## WHAT`, `## METHOD`).

- **WHAT** — the target problem/outcome (why this issue exists, what must change).
- **METHOD** — the currently agreed approach at decision level: chosen direction, known constraints, and scope boundaries that would change execution. Low-level implementation detail belongs in later comments or `notes`, after it becomes true.

## Alternatives Considered

Add an `### Alternatives Considered` subsection under METHOD **only when** one of the following triggers fired:

- Two or more concrete implementations were actually compared during discussion.
- The user rejected one approach and directed another.
- The step 6 feedback loop changed METHOD itself (preserve the prior METHOD alongside the new one).

Do not create the subsection just to fill in alternatives that would be rejected by common sense — the absence of the subsection itself signals "no alternatives were discussed."

## Self-contained, Not Exhaustive

The description must let an executor who has not seen the conversation start work without asking follow-up questions. Record only constraints that are already agreed and would change execution; do not turn the issue into a transcript or full implementation plan.

## Out of Scope

When the boundary is non-trivial, add an `### Out of Scope` subsection under METHOD listing what this issue explicitly does not cover (related components deferred, files not to touch, features excluded).

## Verification

For file-modifying issues, add a `## Verification` section with practical, checkable criteria known at creation time (files that must exist or not exist, behaviors that must hold). Step 5 of the Agent Workflow executes every item, so the section must be unambiguous. Add new verification items later only when execution or feedback makes them necessary.

## Progressive Updates

During execution, record meaningful discoveries, decision changes, and scope additions as comments or `notes` when they become true. The description is the starting contract, not the full history of the work.

## Pre-creation Self-check

Before `bd create`, re-read the description and confirm a reader without conversation context could proceed. If any agreed constraint is missing, or if unresolved choices would change implementation, revise (or ask the user) before creating.

## Issue Type

`bug` (broken behavior) / `feature` (new functionality) / `task` (work item: tests, docs, refactor) / `epic` (large feature with subtasks) / `chore` (maintenance).

## Issue Hierarchy

Do not create hierarchy by default. For a directly executable unit of work, create a single `task`, `bug`, or `chore`. Use hierarchy only when the work needs grouping:

- `feature` groups multiple executable issues for one independently reviewable capability.
- `epic` groups multiple features for one larger initiative.
- When hierarchy is used, prefer `epic -> feature -> executable issue`, where executable issue means `task`, `bug`, or `chore`.

Avoid attaching executable issues directly under an epic unless no meaningful feature grouping exists.

## Priority

`0` critical / `1` high / `2` medium (default) / `3` low / `4` backlog.
