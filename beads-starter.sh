#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ------------------------------------------------------------

STARTER_REPO_USER="seungyeop-lee"
STARTER_REPO_NAME="beads-starter"
STARTER_BRANCH="main"
PAYLOAD_BASE="${PAYLOAD_BASE:-https://raw.githubusercontent.com/${STARTER_REPO_USER}/${STARTER_REPO_NAME}/${STARTER_BRANCH}/payload}"

M_GI_OPEN="# >>> beads-starter >>>"
M_GI_CLOSE="# <<< beads-starter <<<"
M_MD_OPEN="<!-- >>> beads-starter >>> -->"
M_MD_CLOSE="<!-- <<< beads-starter <<< -->"

# --- Usage --------------------------------------------------------------------

usage() {
  cat <<'EOF'
beads-starter — inject beads workflow preset into a repository

Usage: beads-starter.sh <command> [options]

Commands:
  install     Inject beads-starter payload into the current repository
  update      Re-inject payload, preserving the existing prefix (non-interactive)
  uninstall   Remove beads-starter marker regions from the current repository

Run 'beads-starter.sh <command> --help' for command-specific options.
EOF
}

usage_install() {
  cat <<'EOF'
Usage: beads-starter.sh install [--yes|-y]

Interactive install by default. Prompts for the beads issue prefix
(defaults to the current directory name) and for confirmation.

Options:
  --yes, -y   Skip prompts; use the directory name as prefix.
EOF
}

usage_update() {
  cat <<'EOF'
Usage: beads-starter.sh update

Re-inject the current payload into an existing beads-starter installation.
The prefix is auto-detected from docs/beads-starter/bd-setup.md; the command is
non-interactive and takes no options.

Errors out if no beads-starter marker region is found, or if the prefix
cannot be detected.
EOF
}

usage_uninstall() {
  cat <<'EOF'
Usage: beads-starter.sh uninstall [--yes|-y]

Remove beads-starter marker regions from the current repository. Files
that only contained a marker region become empty; delete them manually.

Options:
  --yes, -y   Skip the confirmation prompt.
EOF
}

# --- Helpers ------------------------------------------------------------------

fetch_payload() {
  curl -fsSL "${PAYLOAD_BASE}/${1}"
}

validate_prefix() {
  if [[ ! "$1" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: prefix must match [a-zA-Z0-9_-]+ (got: $1)" >&2
    exit 1
  fi
}

inject_region() {
  local target=$1
  local payload_path=$2
  local m_open=$3
  local m_close=$4

  mkdir -p "$(dirname "$target")"
  touch "$target"

  local content
  content=$(fetch_payload "$payload_path" | sed "s/{{PREFIX}}/${PREFIX}/g")

  local has_open=0 has_close=0
  grep -qxF "$m_open" "$target" && has_open=1
  grep -qxF "$m_close" "$target" && has_close=1

  if [[ $has_open -ne $has_close ]]; then
    echo "Error: $target has mismatched beads-starter markers. Fix manually." >&2
    exit 1
  fi

  if [[ $has_open -eq 1 ]]; then
    PAYLOAD="$content" awk -v mopen="$m_open" -v mclose="$m_close" '
      BEGIN { state = "before"; replacement = ENVIRON["PAYLOAD"] }
      state == "before" {
        if ($0 == mopen) {
          print mopen
          print replacement
          state = "inside"
          next
        }
        print
        next
      }
      state == "inside" {
        if ($0 == mclose) {
          print mclose
          state = "after"
        }
        next
      }
      state == "after" { print }
    ' "$target" > "${target}.tmp"
    mv "${target}.tmp" "$target"
    echo "  updated: $target"
  else
    {
      if [[ -s "$target" ]] && [[ $(tail -c 1 "$target" | wc -l) -eq 0 ]]; then
        printf '\n'
      fi
      if [[ -s "$target" ]]; then
        printf '\n'
      fi
      printf '%s\n' "$m_open"
      printf '%s\n' "$content"
      printf '%s\n' "$m_close"
    } >> "$target"
    echo "  added: $target"
  fi
}

ensure_line() {
  local target=$1
  local line=$2

  mkdir -p "$(dirname "$target")"

  if [[ ! -f "$target" ]]; then
    printf '%s\n' "$line" > "$target"
    echo "  added: $target"
    return 0
  fi

  if grep -qxF "$line" "$target"; then
    echo "  unchanged: $target"
    return 0
  fi

  if [[ -s "$target" ]]; then
    if [[ $(tail -c 1 "$target" | wc -l) -eq 0 ]]; then
      printf '\n' >> "$target"
    fi
    printf '\n' >> "$target"
  fi
  printf '%s\n' "$line" >> "$target"
  echo "  updated: $target"
}

remove_region() {
  local target=$1
  local m_open=$2
  local m_close=$3

  if [[ ! -f "$target" ]]; then
    echo "  skip (not found): $target"
    return 0
  fi

  local has_open=0 has_close=0
  grep -qxF "$m_open" "$target" && has_open=1
  grep -qxF "$m_close" "$target" && has_close=1

  if [[ $has_open -eq 0 && $has_close -eq 0 ]]; then
    echo "  skip (no markers): $target"
    return 0
  fi

  if [[ $has_open -ne $has_close ]]; then
    echo "Error: $target has mismatched beads-starter markers. Fix manually." >&2
    exit 1
  fi

  awk -v mopen="$m_open" -v mclose="$m_close" '
    BEGIN { state = "outside" }
    state == "outside" && $0 == mopen { state = "inside"; next }
    state == "inside" && $0 == mclose { state = "outside"; next }
    state == "outside" { print }
  ' "$target" > "${target}.tmp"
  mv "${target}.tmp" "$target"
  echo "  removed: $target"
}

do_inject() {
  echo "Injecting beads-starter payload (prefix=${PREFIX})..."
  inject_region ".gitignore" "gitignore.part" "$M_GI_OPEN" "$M_GI_CLOSE"
  inject_region "AGENTS.md" "AGENTS.md.part" "$M_MD_OPEN" "$M_MD_CLOSE"
  inject_region "docs/beads-starter/bd-setup.md" "docs/beads-starter/bd-setup.md.part" "$M_MD_OPEN" "$M_MD_CLOSE"
  inject_region "docs/beads-starter/beads-commands.md" "docs/beads-starter/beads-commands.md.part" "$M_MD_OPEN" "$M_MD_CLOSE"
  ensure_line "CLAUDE.md" "@AGENTS.md"
  echo "Done. Next: follow docs/beads-starter/bd-setup.md to install and initialize bd."
}

# --- Subcommand: install ------------------------------------------------------

cmd_install() {
  local yes=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes|-y) yes=1 ;;
      -h|--help) usage_install; exit 0 ;;
      *) echo "Unknown option for 'install': $1" >&2; usage_install >&2; exit 1 ;;
    esac
    shift
  done

  if [[ $yes -eq 0 && ! -r /dev/tty ]]; then
    echo "Error: interactive mode requires a TTY. Use --yes for non-interactive install." >&2
    exit 1
  fi

  local default_prefix
  default_prefix=$(basename "$PWD")

  if [[ $yes -eq 1 ]]; then
    PREFIX="$default_prefix"
  else
    printf 'Project prefix for beads issues [%s]: ' "$default_prefix" > /dev/tty
    read -r input </dev/tty
    PREFIX="${input:-$default_prefix}"
    printf 'Proceed? [Y/n]: ' > /dev/tty
    read -r ans </dev/tty
    case "$ans" in
      ""|y|Y|yes|YES) ;;
      *) echo "Cancelled."; exit 0 ;;
    esac
  fi

  validate_prefix "$PREFIX"
  do_inject
}

# --- Subcommand: update -------------------------------------------------------

cmd_update() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage_update; exit 0 ;;
      *) echo "Unknown option for 'update': $1" >&2; usage_update >&2; exit 1 ;;
    esac
    shift
  done

  if [[ ! -f docs/beads-starter/bd-setup.md ]] || ! grep -qxF "$M_MD_OPEN" docs/beads-starter/bd-setup.md; then
    echo "Error: no beads-starter installation detected (docs/beads-starter/bd-setup.md marker missing)." >&2
    echo "Run 'beads-starter.sh install' first." >&2
    exit 1
  fi

  PREFIX=$(awk -v mopen="$M_MD_OPEN" -v mclose="$M_MD_CLOSE" '
    $0 == mopen { inside=1; next }
    $0 == mclose { inside=0; next }
    inside {
      for (i=1; i<=NF; i++) {
        if ($i == "--prefix") { print $(i+1); exit }
      }
    }
  ' docs/beads-starter/bd-setup.md)

  if [[ -z "${PREFIX:-}" ]]; then
    echo "Error: could not detect prefix from docs/beads-starter/bd-setup.md." >&2
    echo "Edit the file manually or run 'beads-starter.sh uninstall' followed by 'install'." >&2
    exit 1
  fi

  validate_prefix "$PREFIX"
  echo "Detected prefix: ${PREFIX}"
  do_inject
}

# --- Subcommand: uninstall ----------------------------------------------------

cmd_uninstall() {
  local yes=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes|-y) yes=1 ;;
      -h|--help) usage_uninstall; exit 0 ;;
      *) echo "Unknown option for 'uninstall': $1" >&2; usage_uninstall >&2; exit 1 ;;
    esac
    shift
  done

  if [[ $yes -eq 0 ]]; then
    if [[ ! -r /dev/tty ]]; then
      echo "Error: interactive mode requires a TTY. Use --yes for non-interactive uninstall." >&2
      exit 1
    fi
    printf 'Remove beads-starter markers from this repo? [y/N]: ' > /dev/tty
    read -r ans </dev/tty
    case "$ans" in
      y|Y|yes|YES) ;;
      *) echo "Cancelled."; exit 0 ;;
    esac
  fi

  local detected_prefix=""
  if [[ -f .beads/metadata.json ]]; then
    detected_prefix=$(grep -o '"dolt_database"[[:space:]]*:[[:space:]]*"[^"]*"' .beads/metadata.json 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/' || true)
  fi
  local shared_db_path prefix_note
  if [[ -n "$detected_prefix" ]]; then
    shared_db_path="~/.beads/shared-server/dolt/${detected_prefix}/"
    prefix_note="Detected prefix for this repo: ${detected_prefix}"
  else
    shared_db_path="~/.beads/shared-server/dolt/<prefix>/"
    prefix_note="(prefix not auto-detected — <prefix> = value of dolt_database in .beads/metadata.json)"
  fi

  echo "Removing marker regions..."
  remove_region ".gitignore" "$M_GI_OPEN" "$M_GI_CLOSE"
  remove_region "AGENTS.md" "$M_MD_OPEN" "$M_MD_CLOSE"
  remove_region "docs/beads-starter/bd-setup.md" "$M_MD_OPEN" "$M_MD_CLOSE"
  remove_region "docs/beads-starter/beads-commands.md" "$M_MD_OPEN" "$M_MD_CLOSE"
  echo "Done."
  cat <<EOF

beads-starter only removes the marker regions it created.

To remove bd and the data it created, follow the official upstream guide:

  https://github.com/steveyegge/beads/blob/main/docs/UNINSTALLING.md

bd does NOT provide a single uninstall command. The upstream guide
documents the recommended manual procedure (stop server, remove hooks,
unset git config, remove .gitattributes, 'rm -rf .beads/', sync-worktree
cleanup, and 'bd export' for backup before deletion).

TWO DIFFERENCES FROM THE UPSTREAM GUIDE MATTER HERE:

  A) We use shared-server mode, so this project's canonical issue
     database lives OUTSIDE the repo at:
       ${shared_db_path}
     The upstream guide's 'rm -rf .beads/' removes only the repo's
     local cache. To actually delete this project's issue history,
     also run:
       rm -rf ${shared_db_path}
     If the Dolt server has open file handles, stop it first:
       bd dolt stop     # or: bd dolt killall
     Other bd projects on this machine (sibling directories under
     ~/.beads/shared-server/dolt/) are unaffected.

     ${prefix_note}

  B) beads-starter installs bd with '--skip-hooks', so the upstream
     guide's git hook removal steps (pre-commit, prepare-commit-msg,
     post-merge, pre-push, post-checkout) do NOT apply to this repo.

If you want to erase ALL bd state on this machine (nuclear — affects
every bd project on this machine):
  rm -rf ~/.beads/

For CLI binary removal (usually you do NOT want this — keep bd
installed if any other repo might use it), see the "Uninstalling the
'bd' Binary" section of the upstream guide.
EOF
}

# --- Dispatch -----------------------------------------------------------------

if [[ $# -eq 0 ]]; then
  echo "Error: missing command." >&2
  usage >&2
  exit 1
fi

cmd="$1"
shift

case "$cmd" in
  install)   cmd_install "$@" ;;
  update)    cmd_update "$@" ;;
  uninstall) cmd_uninstall "$@" ;;
  -h|--help) usage; exit 0 ;;
  *) echo "Error: unknown command: $cmd" >&2; usage >&2; exit 1 ;;
esac
