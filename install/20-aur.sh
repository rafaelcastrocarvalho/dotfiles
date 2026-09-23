#!/usr/bin/env bash
#
# Bootstrap paru and install the AUR packages listed in packages/pacman/aur.txt.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"
# shellcheck source=../lib/detect.sh
source "$DOTFILES/lib/detect.sh"

log "AUR packages"

if ! have pacman; then
  skip "not an Arch system"
  exit 0
fi

# makepkg refuses to run as root by design, and containers are usually root, so
# there is no way to build an AUR helper there. Skipping is the honest outcome.
if [[ $(detect_profile) == container ]]; then
  skip "container profile -- AUR builds need a non-root user"
  exit 0
fi

if ! have paru; then
  if [[ $EUID -eq 0 ]]; then
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

list=$(package_list aur)
if [[ -z $list ]]; then
  skip "no packages/pacman/aur.txt"
  exit 0
fi

mapfile -t pkgs < <(grep -vE '^[[:space:]]*(#|$)' "$list")
if [[ ${#pkgs[@]} -eq 0 ]]; then
  skip "aur.txt is empty"
  exit 0
fi

run paru -S --needed "${pkgs[@]}"
ok "${#pkgs[@]} AUR packages ensured"
