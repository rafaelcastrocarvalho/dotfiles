#!/usr/bin/env bash
#
# Write the git identity to ~/.config/git/config.local, which this repo does not
# track. Keeping name and email out of a committed script is what stops a typo
# from propagating to every machine -- and lets the repo be public.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"

log "Git identity"

git_dir="${XDG_CONFIG_HOME:-$HOME/.config}/git"
local_config="$git_dir/config.local"
name="" email=""

# A plain ~/.gitconfig takes precedence over ~/.config/git/config, so it would
# silently shadow everything this repo sets. Carry the identity over and move it
# aside rather than leaving two configs fighting.
if [[ -f $HOME/.gitconfig && ! -L $HOME/.gitconfig ]]; then
  name=$(git config --file "$HOME/.gitconfig" user.name || true)
  email=$(git config --file "$HOME/.gitconfig" user.email || true)
  backup="$HOME/.gitconfig.backup.$(stamp)"
  warn "~/.gitconfig shadows $(tilde "$git_dir")/config -- moving it to $(tilde "$backup")"
  run mv "$HOME/.gitconfig" "$backup"
fi

if [[ -f $local_config ]]; then
  skip "$(tilde "$local_config") already exists"
  exit 0
fi

name=${name:-${GIT_AUTHOR_NAME:-}}
email=${email:-${GIT_AUTHOR_EMAIL:-}}

if [[ -z $name || -z $email ]]; then
  if [[ ! -t 0 ]]; then
    warn "no identity found; set GIT_AUTHOR_NAME and GIT_AUTHOR_EMAIL, or write $(tilde "$local_config")"
    exit 0
  fi
  [[ -n $name ]] || read -rp "  git user.name:  " name
  [[ -n $email ]] || read -rp "  git user.email: " email
fi

if [[ ${DRY_RUN:-0} == 1 ]]; then
  skip "would write $(tilde "$local_config") for $name <$email>"
  exit 0
fi

mkdir -p "$git_dir"
cat >"$local_config" <<EOF
# Machine-local git identity. Not tracked by the dotfiles repo.
[user]
	name = $name
	email = $email
EOF
ok "$(tilde "$local_config") written for $name <$email>"
