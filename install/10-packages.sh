#!/usr/bin/env bash
#
# Install the base packages for whichever package manager this system has.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"
# shellcheck source=../lib/detect.sh
source "$DOTFILES/lib/detect.sh"

log "Base packages"

manager=$(detect_manager)
list=$(package_list base)

if [[ $manager == none ]]; then
  warn "no supported package manager (pacman or apt) -- skipping"
  exit 0
fi

if [[ -z $list ]]; then
  warn "no packages/$manager/base.txt -- skipping"
  exit 0
fi

mapfile -t pkgs < <(grep -vE '^[[:space:]]*(#|$)' "$list")
[[ ${#pkgs[@]} -gt 0 ]] || die "$list is empty"

case $manager in
  pacman)
    # --needed makes this a no-op for anything already installed.
    as_root pacman -S --needed "${pkgs[@]}"
    ;;
  apt)
    export DEBIAN_FRONTEND=noninteractive
    as_root apt-get update -qq
    as_root apt-get install -y --no-install-recommends "${pkgs[@]}"

    # Debian ships fd as fdfind to avoid a name clash; telescope and muscle
    # memory both expect `fd`. Test for the shim itself rather than `have fd`:
    # ~/.local/bin is not on PATH until shell/env.sh has run, so `have fd`
    # would be false on every run and this would never settle.
    if have fdfind && [[ ! -e "$HOME/.local/bin/fd" ]]; then
      run mkdir -p "$HOME/.local/bin"
      run ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
      ok "fd -> fdfind shim in ~/.local/bin"
    fi
    ;;
esac

ok "${#pkgs[@]} packages ensured via $manager"
