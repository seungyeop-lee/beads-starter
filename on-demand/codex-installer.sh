#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ------------------------------------------------------------

STARTER_REPO_USER="seungyeop-lee"
STARTER_REPO_NAME="beads-starter"
STARTER_BRANCH="main"
PAYLOAD_BASE="${PAYLOAD_BASE:-https://raw.githubusercontent.com/${STARTER_REPO_USER}/${STARTER_REPO_NAME}/${STARTER_BRANCH}/on-demand/skills}"

SKILLS=(bds-workflow bds-setup bds-status)

FILES_BDS_WORKFLOW=(SKILL.md issue-content.md shell-safety.md commit-rules.md commands.md)
FILES_BDS_SETUP=(SKILL.md)
FILES_BDS_STATUS=(SKILL.md)

# --- Usage --------------------------------------------------------------------

usage() {
  cat <<'EOF'
codex-installer — install beads-starter skills into Codex CLI

Usage: codex-installer.sh <command> [options]

Commands:
  install     Install beads-starter skills (bds-workflow, bds-setup, bds-status)
  update      Re-install over an existing installation in the chosen scope
  uninstall   Remove beads-starter skills from the chosen scope

Run 'codex-installer.sh <command> --help' for command-specific options.
EOF
}

usage_install() {
  cat <<'EOF'
Usage: codex-installer.sh install [--scope=user|project] [--yes|-y]

Installs three skills (bds-workflow, bds-setup, bds-status) into Codex CLI.

Scopes:
  user      ${CODEX_HOME:-~/.codex}/skills/bds-*/  (machine-wide)
  project   <cwd>/.agents/skills/bds-*/            (current repo)

Options:
  --scope=user|project   Required with --yes; otherwise prompted.
  --yes, -y              Skip the confirmation prompt.
EOF
}

usage_update() {
  cat <<'EOF'
Usage: codex-installer.sh update [--scope=user|project] [--yes|-y]

Re-installs the three skills, replacing any existing copy in the chosen scope.
Errors out if no beads-starter skill is detected in the chosen scope.

Options:
  --scope=user|project   Required with --yes; otherwise prompted.
  --yes, -y              Skip the confirmation prompt.
EOF
}

usage_uninstall() {
  cat <<'EOF'
Usage: codex-installer.sh uninstall [--scope=user|project] [--yes|-y]

Removes the three skill directories from the chosen scope. Other skills
under the same parent directory are not touched.

Options:
  --scope=user|project   Required with --yes; otherwise prompted.
  --yes, -y              Skip the confirmation prompt.
EOF
}

# --- Helpers ------------------------------------------------------------------

fetch_payload() {
  curl -fsSL "${PAYLOAD_BASE}/${1}"
}

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

files_for_skill() {
  case "$1" in
    bds-workflow) printf '%s\n' "${FILES_BDS_WORKFLOW[@]}" ;;
    bds-setup)    printf '%s\n' "${FILES_BDS_SETUP[@]}" ;;
    bds-status)   printf '%s\n' "${FILES_BDS_STATUS[@]}" ;;
    *) echo "Error: unknown skill: $1" >&2; exit 1 ;;
  esac
}

install_skill() {
  local base_dir=$1
  local skill=$2
  local target_dir="${base_dir}/${skill}"

  rm -rf "$target_dir"
  mkdir -p "$target_dir"

  while IFS= read -r f; do
    fetch_payload "${skill}/${f}" > "${target_dir}/${f}"
  done < <(files_for_skill "$skill")

  echo "  installed: ${target_dir}"
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
  for s in "${SKILLS[@]}"; do
    if [[ -d "${base_dir}/${s}" ]]; then
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
  local cmd=$1 scope=$2 yes=$3
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

cmd_install() {
  local scope="" yes=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --scope=*) scope="${1#--scope=}" ;;
      --scope) shift; scope="${1:-}" ;;
      --yes|-y) yes=1 ;;
      -h|--help) usage_install; exit 0 ;;
      *) echo "Unknown option for 'install': $1" >&2; usage_install >&2; exit 1 ;;
    esac
    shift
  done

  resolve_scope_and_dir install "$scope" "$yes"

  if [[ $yes -ne 1 ]]; then
    confirm "Install beads-starter skills into ${RESOLVED_DIR}?" || { echo "Cancelled."; exit 0; }
  fi

  echo "Installing beads-starter skills into ${RESOLVED_DIR}..."
  mkdir -p "$RESOLVED_DIR"
  for s in "${SKILLS[@]}"; do
    install_skill "$RESOLVED_DIR" "$s"
  done
  echo "Done."
  echo "If Codex CLI is currently running, restart it so the new skills are picked up."
}

cmd_update() {
  local scope="" yes=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --scope=*) scope="${1#--scope=}" ;;
      --scope) shift; scope="${1:-}" ;;
      --yes|-y) yes=1 ;;
      -h|--help) usage_update; exit 0 ;;
      *) echo "Unknown option for 'update': $1" >&2; usage_update >&2; exit 1 ;;
    esac
    shift
  done

  resolve_scope_and_dir update "$scope" "$yes"

  if ! is_installed "$RESOLVED_DIR"; then
    echo "Error: no beads-starter skill found in ${RESOLVED_DIR}." >&2
    echo "Run 'codex-installer.sh install --scope=${RESOLVED_SCOPE}' first." >&2
    exit 1
  fi

  if [[ $yes -ne 1 ]]; then
    confirm "Re-install beads-starter skills into ${RESOLVED_DIR}?" || { echo "Cancelled."; exit 0; }
  fi

  echo "Updating beads-starter skills in ${RESOLVED_DIR}..."
  for s in "${SKILLS[@]}"; do
    install_skill "$RESOLVED_DIR" "$s"
  done
  echo "Done."
  echo "If Codex CLI is currently running, restart it so the refreshed skills are picked up."
}

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

  resolve_scope_and_dir uninstall "$scope" "$yes"

  if ! is_installed "$RESOLVED_DIR"; then
    echo "No beads-starter skills found in ${RESOLVED_DIR}. Nothing to do."
    exit 0
  fi

  if [[ $yes -ne 1 ]]; then
    confirm "Remove beads-starter skills from ${RESOLVED_DIR}?" || { echo "Cancelled."; exit 0; }
  fi

  echo "Removing beads-starter skills from ${RESOLVED_DIR}..."
  for s in "${SKILLS[@]}"; do
    remove_skill "$RESOLVED_DIR" "$s"
  done
  echo "Done."
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
