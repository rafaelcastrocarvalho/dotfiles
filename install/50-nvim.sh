#!/usr/bin/env bash
#
# Restore the Neovim plugin set from the committed lazy-lock.json.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"

log "Neovim plugins"

if ! have nvim; then
  warn "neovim is not installed -- run step 10 first"
  exit 0
fi

if [[ ! -e "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua" ]]; then
  warn "nvim config is not linked yet -- run step 40 first"
  exit 0
fi

# `restore` honours lazy-lock.json; `sync` would ignore it and pull latest.
# Headless so this never blocks a non-interactive run on a "Press ENTER" prompt.
run nvim --headless "+Lazy! restore" +qa
ok "plugins restored from lazy-lock.json"
