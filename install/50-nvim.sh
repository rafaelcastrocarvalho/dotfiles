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

# Parsers are built by the tree-sitter CLI, which comes from packages/*/base.txt.
# Without it every parser fails with ENOENT and there is no highlighting.
if ! have tree-sitter; then
  warn "tree-sitter CLI missing -- parsers cannot be built (run step 10)"
  exit 0
fi

log "Treesitter parsers"
if [[ ${DRY_RUN:-0} == 1 ]]; then
  skip "would build the parsers declared in treesitter.lua"
else
  # Non-fatal: this drives plugin internals, and a bootstrap must not fail if
  # they change. Worst case the parsers build on the first real nvim session.
  out=$(nvim --headless -c "luafile $DOTFILES/lib/nvim-treesitter-sync.lua" -c 'qa' 2>&1 | tail -1)
  ok "${out:-done}"
fi
