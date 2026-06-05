---
name: versionup
description: Use when bumping the beads-starter on-demand plugin version by major, minor, or patch component and committing the result.
---

# on-demand Plugin Version Bump

## Overview

Bumps the on-demand plugin version in both manifest files and commits with the exact required message format.

## Target Files

Both files must be updated together — never one without the other:

| File | Field |
|------|-------|
| `on-demand/.claude-plugin/plugin.json` | `"version"` |
| `on-demand/.codex-plugin/plugin.json` | `"version"` |

## Semver Rules

Current version: read from `on-demand/.claude-plugin/plugin.json` (source of truth). The two files must always hold the same version — if they differ, stop and report the mismatch instead of bumping.

| Parameter | Change |
|-----------|--------|
| `major` | X+1.0.0 |
| `minor` | X.Y+1.0 |
| `patch` | X.Y.Z+1 |

When `major` bumps: reset minor and patch to 0.
When `minor` bumps: reset patch to 0.
When `patch` bumps: keep major and minor unchanged.

## Steps

1. Read current version from `on-demand/.claude-plugin/plugin.json`
2. Verify `on-demand/.codex-plugin/plugin.json` has the same version
3. Calculate new version per the semver rules above
4. Update `"version"` field in `on-demand/.claude-plugin/plugin.json`
5. Update `"version"` field in `on-demand/.codex-plugin/plugin.json`
6. Stage both files:
   ```
   git add on-demand/.claude-plugin/plugin.json on-demand/.codex-plugin/plugin.json
   ```
7. Commit with **exact** message format — no other format is acceptable:
   ```
   git commit -m "release: on-demand 플러그인 버전 [new-version]"
   ```
   Example: `git commit -m "release: on-demand 플러그인 버전 0.4.0"`

## Out of Scope

- Do not push to `main` — pushing is the deploy step and stays a manual decision.
- Do not touch `always-on/` or the root shim; they are not versioned.

## Common Mistakes

| Mistake | Correct |
|---------|---------|
| `"chore: bump version to 0.4.0"` | `"release: on-demand 플러그인 버전 0.4.0"` |
| `"release: v0.4.0"` | `"release: on-demand 플러그인 버전 0.4.0"` |
| Updating only one file | Both files required |
| Staging with `git add .` | Stage only the two manifest files |
