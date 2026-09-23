#!/usr/bin/env bash
#
# Bootstrap paru and install the AUR packages listed in packages/aur.txt.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"

log "AUR packages"

if ! have pacman; then
  skip "no pacman on this system"
  exit 0
fi

if ! have paru; then
  if [[ $EUID -eq 0 ]]; then
    # makepkg refuses to run as root by design, so there is no way to build an
    # AUR helper here. Containers land on this branch; phase 3 makes it explicit.
    warn "running as root -- makepkg cannot build paru, skipping AUR"
    exit 0
  fi

  log "bootstrapping paru"
  if [[ ${DRY_RUN:-0} == 1 ]]; then
    skip "would clone and makepkg -si paru"
  else
    build=$(mktemp -d)
    trap 'rm -rf "$build"' EXIT
    git clone --depth 1 https://aur.archlinux.org/paru.git "$build/paru"
    (cd "$build/paru" && makepkg -si --noconfirm)
    ok "paru installed"
  fi
fi

mapfile -t pkgs < <(grep -vE '^[[:space:]]*(#|$)' "$DOTFILES/packages/aur.txt")
if [[ ${#pkgs[@]} -eq 0 ]]; then
  skip "packages/aur.txt is empty"
  exit 0
fi

run paru -S --needed "${pkgs[@]}"
ok "${#pkgs[@]} AUR packages ensured"
