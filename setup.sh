#!/usr/bin/env bash
#
# Bootstrap this machine from the dotfiles repo.
#
#   ./setup.sh                 run every step, in order
#   ./setup.sh --dry-run       print what would happen, change nothing
#   ./setup.sh --only 40       run only the step whose name starts with "40"
#   ./setup.sh --list          list the steps and exit
#   ./setup.sh --profile NAME  force workstation or container (default: detect)
#
# Every step is idempotent: running this again is how you apply updates.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES

# shellcheck source=lib/common.sh
source "$DOTFILES/lib/common.sh"
# shellcheck source=lib/detect.sh
source "$DOTFILES/lib/detect.sh"

DRY_RUN=0
ONLY=""
PROFILE="${PROFILE:-}"

usage() {
  sed -n '3,11p' "${BASH_SOURCE[0]}" | sed 's/^#\s\?//'
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -n | --dry-run) DRY_RUN=1 ;;
    --only)
      ONLY=${2:-}
      [[ -n $ONLY ]] || die "--only needs a step name, e.g. --only 40"
      shift
      ;;
    --profile)
      PROFILE=${2:-}
      case $PROFILE in
        workstation | container) ;;
        *) die "--profile must be workstation or container, got '${PROFILE:-}'" ;;
      esac
      shift
      ;;
    --list)
      for step in "$DOTFILES"/install/*.sh; do
        printf '  %s\n' "$(basename "$step" .sh)"
      done
      exit 0
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

PROFILE=$(detect_profile)
export DRY_RUN PROFILE

log "profile: $PROFILE  ·  packages: $(detect_manager)"
[[ $DRY_RUN == 1 ]] && log "dry run: nothing will be changed"

ran=0
for step in "$DOTFILES"/install/*.sh; do
  name=$(basename "$step" .sh)
  [[ -n $ONLY && $name != "$ONLY"* ]] && continue
  # Each step runs in its own process with its own `set -e`, so a broken step
  # stops the run instead of being silently skipped.
  bash "$step"
  ran=$((ran + 1))
done

[[ $ran -gt 0 ]] || die "no step matched --only '$ONLY' (try --list)"

log "done"
