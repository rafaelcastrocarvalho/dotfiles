# Linked to ~/.bashrc by install/40-link.sh. Edit it in the repo, not in $HOME.
#
# bash has no XDG support for its rc file -- ~/.bashrc is hardcoded in bash 5.3
# -- so unlike the other shells' config this one cannot move out of $HOME.

# Interactive shells only.
case $- in
  *i*) ;;
  *) return ;;
esac

# Resolve the repo through this file's own symlink, so nothing has to hardcode
# where the dotfiles were cloned.
DOTFILES=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)
export DOTFILES

# Shared with zsh, so a function defined once works in both shells.
source "$DOTFILES/shell/env.sh"
source "$DOTFILES/shell/aliases.sh"
source "$DOTFILES/shell/functions.sh"

HISTFILE="$XDG_STATE_HOME/bash/history"
HISTSIZE=50000
HISTFILESIZE=50000

# Prompt: working directory, then the arrow on its own line.
_txtylw='\[\033[1;33m\]'
_fgcolor='\[\033[0m\]'
_arrow=$'\xe2\x86\x92'
PS1="\w${_txtylw} \n${_arrow} ${_fgcolor}"

# Orange badge so a container shell is never mistaken for the host one.
if [ -n "${DOTFILES_CONTAINER:-}" ]; then
  PS1="\[\033[48;5;208;38;5;16m\] ${DOTFILES_CONTAINER} \[\033[0m\] $PS1"
fi

GIT_PROMPT_ONLY_IN_REPO=1
GIT_PROMPT_END="${_txtylw} \n${_arrow} ${_fgcolor}"

if [[ -r /usr/share/git/completion/git-completion.bash ]]; then
  source /usr/share/git/completion/git-completion.bash
fi
if [[ -r /usr/share/git/completion/git-prompt.sh ]]; then
  source /usr/share/git/completion/git-prompt.sh
fi

# Machine-local overrides, never tracked.
[[ -f "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
