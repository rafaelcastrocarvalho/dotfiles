#!/usr/bin/env bash
#
# Install the base packages listed in packages/base.txt.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"

log "Base packages"

if ! have pacman; then
  skip "no pacman on this system -- see README, profiles arrive in phase 3"
  exit 0
fi

mapfile -t pkgs < <(grep -vE '^[[:space:]]*(#|$)' "$DOTFILES/packages/base.txt")
[[ ${#pkgs[@]} -gt 0 ]] || die "packages/base.txt is empty"

# --needed makes this a no-op for anything already installed.
run sudo pacman -S --needed "${pkgs[@]}"
ok "${#pkgs[@]} packages ensured"
