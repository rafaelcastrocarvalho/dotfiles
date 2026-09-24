# Linked to ~/.config/zsh/.zshrc by install/40-link.sh, found via ZDOTDIR which
# ~/.zshenv sets. Edit it in the repo, not in $HOME.
#
# DOTFILES is already exported by .zshenv, which runs first.

# XDG paths and relocated config, shared with bash. Sourced before oh-my-zsh so
# ZSH and ZSH_COMPDUMP are in place when it loads.
source "$DOTFILES/shell/env.sh"

ZSH_THEME="robbyrussell"

# Keep the completion dump out of $HOME; it is cache, and there is one per zsh
# version, so they pile up.
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes for themes and
# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins for the plugin list.
plugins=(asdf git git-prompt vi-mode)

# A bare container image may have zsh but no oh-my-zsh. Everything below still
# works without it, so say so once instead of erroring at every prompt.
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  print -u2 "dotfiles: no oh-my-zsh at $ZSH -- run: setup.sh --only 30"
fi

# Orange badge so a container shell is never mistaken for the host one. Set
# after the theme has run, so it survives whatever ZSH_THEME is.
#
# Raw escapes instead of %K{208}/%F{16}: zsh checks terminfo before emitting a
# 256-colour prompt escape, and `devcontainer exec` hands the shell TERM=xterm,
# which claims 8 colours -- so zsh silently dropped the colour and left the
# text. bash never checks, which is why the same badge worked there. %{...%}
# marks the bytes as zero-width so zsh still measures the line correctly.
if [[ -n ${DOTFILES_CONTAINER:-} ]]; then
  _badge_on=$'\e[48;5;208;38;5;16m'
  _badge_off=$'\e[0m'
  PROMPT="%{${_badge_on}%} ${DOTFILES_CONTAINER} %{${_badge_off}%} ${PROMPT}"
  unset _badge_on _badge_off
fi

# vi keybindings. This used to be appended to ~/.zshrc by setup.sh on every run,
# which is how the file accumulated duplicates.
bindkey -v

source "$DOTFILES/shell/aliases.sh"
source "$DOTFILES/shell/functions.sh"

if [[ -x /usr/bin/terraform ]]; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/bin/terraform terraform
fi

# Machine-local overrides, never tracked.
[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
