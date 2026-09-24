#!/usr/bin/env bash
#
# Move shell and REPL history to the XDG paths shell/env.sh points the tools at.
#
# History is data, not cache. Relocating the variable without moving the file
# leaves years of it behind in $HOME, still on disk and read by nothing -- the
# shell just starts empty and it looks like the history was lost.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"

log "History files"

state="${XDG_STATE_HOME:-$HOME/.local/state}"

# <path under $HOME>:<path under $state>. Keep in step with shell/env.sh; a
# variable there without an entry here is the bug this step exists to prevent.
pairs=(
  ".zsh_history:zsh/history"
  ".bash_history:bash/history"
  ".lesshst:less/history"
  ".psql_history:psql_history"
  ".mysql_history:mysql_history"
  ".sqlite_history:sqlite_history"
  ".rediscli_history:rediscli_history"
  ".node_repl_history:node_repl_history"
  ".python_history:python_history"
)

moved=0
conflicts=0

for pair in "${pairs[@]}"; do
  old="$HOME/${pair%%:*}"
  new="$state/${pair#*:}"

  [[ -f $old ]] || continue

  if [[ -e $new ]]; then
    # Both exist: the new one has already collected entries. Concatenating
    # blindly would duplicate whatever overlaps, so this reports and leaves
    # both files intact rather than guessing.
    warn "$(tilde "$old") and $(tilde "$new") both exist -- not merging for you"
    warn "   to join them, oldest first:"
    warn "   cat '$old' '$new' > '$new.joined' && mv '$new.joined' '$new' && rm '$old'"
    conflicts=$((conflicts + 1))
    continue
  fi

  run mkdir -p "$(dirname "$new")"
  run mv "$old" "$new"
  ok "$(tilde "$old") -> $(tilde "$new")"
  moved=$((moved + 1))
done

if [[ $moved -eq 0 && $conflicts -eq 0 ]]; then
  skip "no history left in \$HOME"
fi
