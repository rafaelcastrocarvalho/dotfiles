# Environment shared by bash and zsh. Keep this POSIX-ish: both shells read it.

export EDITOR=nvim
export VISUAL=nvim

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# --- PATH ------------------------------------------------------------------

# Prepend only if absent, so re-sourcing an rc file does not grow PATH.
_path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}

# asdf 0.16+ is a compiled Go binary: there is no asdf.sh to source any more,
# the shim directory on PATH is the whole integration.
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
_path_prepend "$ASDF_DATA_DIR/shims"

_path_prepend "$HOME/.local/bin"

export PATH
unset -f _path_prepend

# --- config relocated out of $HOME -----------------------------------------

# These tools keep their config wherever an environment variable points, so the
# file lives under pkg/<tool>/.config/ and this is what makes them look there.
export ASDF_CONFIG_FILE="$XDG_CONFIG_HOME/asdf/asdfrc"

# readline has no XDG support of its own (verified on readline 8.3: a file at
# $XDG_CONFIG_HOME/readline/inputrc is ignored). INPUTRC is the only lever.
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

export ZSH="$XDG_DATA_HOME/oh-my-zsh"

# --- history and state out of $HOME ----------------------------------------

# Only files that regenerate themselves are relocated here. Nothing below
# breaks if the old file is never migrated -- it is simply rewritten in the new
# place. Config holding credentials (~/.docker, ~/.aws) is deliberately left
# alone: moving that is a data migration, not a config change.
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
export MYSQL_HISTFILE="$XDG_STATE_HOME/mysql_history"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite_history"
export REDISCLI_HISTFILE="$XDG_STATE_HOME/rediscli_history"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
# Honoured natively since Python 3.13.
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"

# A history file is not created if its directory is missing, so make them once.
for _d in "$XDG_STATE_HOME" "$XDG_STATE_HOME/less" "$XDG_STATE_HOME/bash" \
  "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh"; do
  [ -d "$_d" ] || mkdir -p "$_d"
done
unset _d

# --- container badge -------------------------------------------------------

# dcup exports DOTFILES_CONTAINER with the project name; anything else that put
# us in a container still gets a badge, just a generic one. Empty on the host,
# which is what keeps the badge out of the way there.
if [ -z "${DOTFILES_CONTAINER:-}" ] && { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; }; then
  DOTFILES_CONTAINER=container
fi
if [ -n "${DOTFILES_CONTAINER:-}" ]; then
  export DOTFILES_CONTAINER
fi
