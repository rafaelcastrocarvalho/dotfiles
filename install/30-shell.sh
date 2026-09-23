#!/usr/bin/env bash
#
# Install oh-my-zsh and make zsh the login shell.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"

log "Shell"

if ! have zsh; then
  warn "zsh is not installed -- run step 10 first"
  exit 0
fi

# Must match the ZSH export in shell/env.sh.
ZSH_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
legacy_omz="$HOME/.oh-my-zsh"

if [[ -d $ZSH_DIR ]]; then
  skip "oh-my-zsh already at $(tilde "$ZSH_DIR")"
elif [[ -d $legacy_omz ]]; then
  # Move rather than re-clone: a local install may carry custom plugins/themes.
  log "moving oh-my-zsh out of \$HOME"
  run mkdir -p "$(dirname "$ZSH_DIR")"
  run mv "$legacy_omz" "$ZSH_DIR"
  ok "$(tilde "$legacy_omz") -> $(tilde "$ZSH_DIR")"
else
  run mkdir -p "$(dirname "$ZSH_DIR")"
  run git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
  ok "oh-my-zsh installed"
fi

# With ZDOTDIR pointing at ~/.config/zsh, a leftover ~/.zshrc is never read
# again. Move it aside so it cannot masquerade as the live config.
if [[ -e $HOME/.zshrc && ! -L $HOME/.zshrc ]]; then
  backup="$HOME/.zshrc.backup.$(stamp)"
  warn "ZDOTDIR makes ~/.zshrc dead -- moving it to $(tilde "$backup")"
  run mv "$HOME/.zshrc" "$backup"
fi

zsh_path=$(command -v zsh)
# Compare resolved paths: on Arch /bin is a symlink to /usr/bin, so $SHELL can
# read /bin/zsh while command -v reports /usr/bin/zsh for the very same shell.
if [[ $(readlink -f "${SHELL:-/nonexistent}") == "$(readlink -f "$zsh_path")" ]]; then
  skip "zsh is already the login shell"
elif [[ ! -t 0 ]]; then
  # chsh prompts for a password, which a non-interactive run cannot answer.
  warn "login shell is ${SHELL:-unset}; run: chsh -s $zsh_path"
else
  run chsh -s "$zsh_path" || warn "chsh failed -- run it yourself: chsh -s $zsh_path"
fi
