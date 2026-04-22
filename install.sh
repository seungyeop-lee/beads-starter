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

# --- Helpers ------------------------------------------------------------------

usage() {
  cat <<'EOF'
beads-starter installer

Usage: install.sh [--yes] [--uninstall] [-h|--help]

  (no flag)    Interactive install
  --yes, -y    Non-interactive install using defaults
  --uninstall  Remove beads-starter marker regions from this repo
  -h, --help   Show this help
EOF
}

fetch_payload() {
  curl -fsSL "${PAYLOAD_BASE}/${1}"
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

# --- Arg parsing --------------------------------------------------------------

YES=0
UNINSTALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y) YES=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

if [[ $YES -eq 0 && ! -r /dev/tty ]]; then
  echo "Error: interactive mode requires a TTY. Use --yes for non-interactive install." >&2
  exit 1
fi

# --- Uninstall ----------------------------------------------------------------

if [[ $UNINSTALL -eq 1 ]]; then
  if [[ $YES -eq 0 ]]; then
    printf 'Remove beads-starter markers from this repo? [y/N]: ' > /dev/tty
    read -r ans </dev/tty
    case "$ans" in
      y|Y|yes|YES) ;;
      *) echo "Cancelled."; exit 0 ;;
    esac
  fi
  # Detect the beads prefix for this repo (used to locate the project's
  # database inside the shared Dolt server). Best-effort parse of
  # .beads/metadata.json; falls back to a <prefix> placeholder if missing.
  detected_prefix=""
  if [[ -f .beads/metadata.json ]]; then
    detected_prefix=$(grep -o '"dolt_database"[[:space:]]*:[[:space:]]*"[^"]*"' .beads/metadata.json 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/' || true)
  fi
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
  remove_region "docs/bd-setup.md" "$M_MD_OPEN" "$M_MD_CLOSE"
  remove_region "docs/beads-commands.md" "$M_MD_OPEN" "$M_MD_CLOSE"
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
  exit 0
fi

# --- Install ------------------------------------------------------------------

DEFAULT_PREFIX=$(basename "$PWD")

if [[ $YES -eq 1 ]]; then
  PREFIX="$DEFAULT_PREFIX"
else
  printf 'Project prefix for beads issues [%s]: ' "$DEFAULT_PREFIX" > /dev/tty
  read -r input </dev/tty
  PREFIX="${input:-$DEFAULT_PREFIX}"
  printf 'Proceed? [Y/n]: ' > /dev/tty
  read -r ans </dev/tty
  case "$ans" in
    ""|y|Y|yes|YES) ;;
    *) echo "Cancelled."; exit 0 ;;
  esac
fi

if [[ ! "$PREFIX" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: prefix must match [a-zA-Z0-9_-]+ (got: $PREFIX)" >&2
  exit 1
fi

echo "Injecting beads-starter payload (prefix=${PREFIX})..."
inject_region ".gitignore" "gitignore.part" "$M_GI_OPEN" "$M_GI_CLOSE"
inject_region "AGENTS.md" "AGENTS.md.part" "$M_MD_OPEN" "$M_MD_CLOSE"
inject_region "docs/bd-setup.md" "docs/bd-setup.md.part" "$M_MD_OPEN" "$M_MD_CLOSE"
inject_region "docs/beads-commands.md" "docs/beads-commands.md.part" "$M_MD_OPEN" "$M_MD_CLOSE"
ensure_line "CLAUDE.md" "@AGENTS.md"
echo "Done. Next: follow docs/bd-setup.md to install and initialize bd."
