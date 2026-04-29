# beads-starter

*English · [한국어](README.ko.md)*

> Two ways to bring [beads](https://github.com/steveyegge/beads) workflow
> conventions into a project: an always-on bash installer, and an on-demand
> skill bundle for Claude Code or Codex CLI.
>
> **Unofficial.** Not affiliated with the beads project.

## Choose a mode

| | Always-on mode | On-demand mode |
|---|---|---|
| Mechanism | Bash installer injects content into target repo files | Three skills loaded only on explicit invocation |
| When the workflow applies | Every session, automatically | Only when you explicitly invoke the `bds-workflow` skill |
| Distribution | `curl | bash` | Claude Code plugin marketplace, or `curl | bash` (Codex) |
| Agent compatibility | Any agent that reads `AGENTS.md` (Claude Code, Cursor, Codex, …) | Claude Code, Codex CLI |
| Pick this if | You want the workflow to apply to every task without thinking about it, or you use multiple AI agents | You want to opt in per task |

The two modes are mutually exclusive — pick one. If both are installed in the
same repo, the workflow rules will be loaded twice.

- **Always-on mode** — see [`always-on/README.md`](always-on/README.md)
- **On-demand mode** — see [`on-demand/README.md`](on-demand/README.md)

## Operating mode

Both modes configure beads in **shared-server** mode (local only, no Dolt
remote). The setup targets git worktree workflows and single-machine use.
The actual `bd init` command ships verbatim either in the injected
`docs/beads-starter/bd-setup.md` (always-on) or in the `bds-setup` skill
(on-demand).

## License

[MIT](LICENSE)
