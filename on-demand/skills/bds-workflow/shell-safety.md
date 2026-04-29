# Shell Safety for bd

When invoking `bd` with narrative arguments (`--description`, `--notes`, `--reason`, `bd comments add` body, etc.), **wrap the value in single quotes** by default:

```bash
bd close PROJECT-42 --reason='Commit abc1234: applied `Decision changed` convention'
```

Rationale: inside double quotes, the shell still expands `` ` ``, `$`, and `!`. Backtick-wrapped text such as `` `Added via feedback:` `` is then treated as command substitution and silently truncated from the stored value.

Switch to a heredoc form **only when** the content itself contains a single quote:

```bash
bd close PROJECT-42 --reason="$(cat <<'EOF'
Use this form only when the body contains a single quote.
EOF
)"
```
