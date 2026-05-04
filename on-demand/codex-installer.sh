#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ------------------------------------------------------------

STARTER_REPO_USER="seungyeop-lee"
STARTER_REPO_NAME="beads-starter"

SKILLS=(bds-workflow bds-setup bds-status)

# --- Usage --------------------------------------------------------------------

plugin_install_instructions() {
  cat <<EOF
Codex plugin install is now the supported path:

  codex plugin marketplace add ${STARTER_REPO_USER}/${STARTER_REPO_NAME}

Then open Codex, run /plugins, choose the beads-starter marketplace, and
install the beads-starter plugin.
EOF
}

usage() {
  cat <<'EOF'
codex-installer — legacy direct-skill cleanup for beads-starter

Usage: codex-installer.sh uninstall [--scope=user|project] [--yes|-y]

Commands:
  uninstall   Remove legacy direct-skill copies from the chosen scope

The old install/update commands have been removed. Use the Codex plugin
marketplace path for new installations.
EOF
}

usage_uninstall() {
  cat <<'EOF'
Usage: codex-installer.sh uninstall [--scope=user|project] [--yes|-y]

Removes legacy direct-skill directories from the chosen scope. Other skills
under the same parent directory are not touched.

Scopes:
  user      ${CODEX_HOME:-~/.codex}/skills/bds-*/  (machine-wide)
  project   <cwd>/.agents/skills/bds-*/            (current repo)

Options:
  --scope=user|project   Required with --yes; otherwise prompted.
  --yes, -y              Skip the confirmation prompt.
EOF
}

# --- Helpers ------------------------------------------------------------------

resolve_scope_dir() {
  case "$1" in
    user)
      local home="${CODEX_HOME:-$HOME/.codex}"
      printf '%s/skills' "$home"
      ;;
    project)
      printf '%s/.agents/skills' "$PWD"
      ;;
    *)
      echo "Error: invalid scope: $1 (expected 'user' or 'project')" >&2
      exit 1
      ;;
  esac
}

remove_skill() {
  local base_dir=$1
  local skill=$2
  local target_dir="${base_dir}/${skill}"

  if [[ -d "$target_dir" ]]; then
    rm -rf "$target_dir"
    echo "  removed: ${target_dir}"
  else
    echo "  skip (not found): ${target_dir}"
  fi
}

is_installed() {
  local base_dir=$1
  local skill
  for skill in "${SKILLS[@]}"; do
    if [[ -d "${base_dir}/${skill}" ]]; then
      return 0
    fi
  done
  return 1
}

prompt_scope() {
  if [[ ! -r /dev/tty ]]; then
    echo "Error: --scope is required when no TTY is available." >&2
    exit 1
  fi
  printf 'Scope [user/project]: ' > /dev/tty
  read -r ans </dev/tty
  case "$ans" in
    user|project) printf '%s' "$ans" ;;
    *) echo "Error: scope must be 'user' or 'project'." >&2; exit 1 ;;
  esac
}

confirm() {
  local prompt=$1
  if [[ ! -r /dev/tty ]]; then
    echo "Error: interactive mode requires a TTY. Use --yes for non-interactive." >&2
    exit 1
  fi
  printf '%s [y/N]: ' "$prompt" > /dev/tty
  read -r ans </dev/tty
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

resolve_scope_and_dir() {
  local scope=$1 yes=$2
  if [[ -z "$scope" ]]; then
    if [[ $yes -eq 1 ]]; then
      echo "Error: --scope is required with --yes" >&2
      exit 1
    fi
    scope=$(prompt_scope)
  fi
  case "$scope" in
    user|project) ;;
    *) echo "Error: invalid --scope: $scope (expected 'user' or 'project')" >&2; exit 1 ;;
  esac
  RESOLVED_SCOPE="$scope"
  RESOLVED_DIR=$(resolve_scope_dir "$scope")
}

# --- Subcommands --------------------------------------------------------------

cmd_uninstall() {
  local scope="" yes=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --scope=*) scope="${1#--scope=}" ;;
      --scope) shift; scope="${1:-}" ;;
      --yes|-y) yes=1 ;;
      -h|--help) usage_uninstall; exit 0 ;;
      *) echo "Unknown option for 'uninstall': $1" >&2; usage_uninstall >&2; exit 1 ;;
    esac
    shift
  done

  resolve_scope_and_dir "$scope" "$yes"

  if ! is_installed "$RESOLVED_DIR"; then
    echo "No legacy beads-starter skills found in ${RESOLVED_DIR}. Nothing to do."
    exit 0
  fi

  if [[ $yes -ne 1 ]]; then
    confirm "Remove legacy beads-starter skills from ${RESOLVED_DIR}?" || { echo "Cancelled."; exit 0; }
  fi

  echo "Removing legacy beads-starter skills from ${RESOLVED_DIR}..."
  local skill
  for skill in "${SKILLS[@]}"; do
    remove_skill "$RESOLVED_DIR" "$skill"
  done
  echo "Done."
}

removed_command() {
  local cmd=$1
  echo "Error: '${cmd}' has been removed from codex-installer.sh." >&2
  echo >&2
  plugin_install_instructions >&2
  echo >&2
  usage >&2
  exit 1
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
  uninstall) cmd_uninstall "$@" ;;
  install|update) removed_command "$cmd" ;;
  -h|--help) usage; exit 0 ;;
  *) echo "Error: unknown command: $cmd" >&2; usage >&2; exit 1 ;;
esac
