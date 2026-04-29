# Commit Rules

For step 7 of the Agent Workflow.

- Stage only files belonging to the closed issue; report any unrelated working-tree changes to the user instead of sweeping them in.
- Follow the existing commit message convention: `chore:`, `feat(scope):`, `fix:`, etc.
- Never run `git push`.
- Never bypass git hooks (`--no-verify` or any equivalent flag/env). If a hook fails, fix the underlying issue and retry.
