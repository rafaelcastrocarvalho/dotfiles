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

source "$ZSH/oh-my-zsh.sh"

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
