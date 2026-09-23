#!/usr/bin/env bash
#
# The symlink farm.
#
# Every directory under pkg/ is a package whose tree mirrors $HOME: the file
# pkg/tmux/.config/tmux/tmux.conf is linked to ~/.config/tmux/tmux.conf. That is
# the layout GNU stow uses, so `stow -d pkg -t ~ tmux` would do the same job --
# the convention is deliberate, and nothing here locks you into this script.
#
# Requires DOTFILES to be set and lib/common.sh to be sourced.

# Trees linked whole, instead of file by file. Use this only for directories we
# own completely and edit often, so a newly added file shows up without
# re-running setup. A directory that has to hold a generated *.local file must
# NOT be listed here -- the generated file would land inside the repo.
DIR_LINKS=(
  ".config/nvim"
)

_is_under_dir_link() {
  local rel=$1 d
  for d in "${DIR_LINKS[@]}"; do
    [[ $rel == "$d" || $rel == "$d"/* ]] && return 0
  done
  return 1
}

# link_one <source> <target>
#
# Idempotent: an existing correct link is left alone, a wrong link is replaced,
# and anything else is moved aside before linking so nothing is ever destroyed.
link_one() {
  local src=$1 tgt=$2

  if [[ -L $tgt ]]; then
    if [[ $(readlink -f "$tgt") == "$(readlink -f "$src")" ]]; then
      skip "$(tilde "$tgt")"
      return 0
    fi
  elif [[ -e $tgt ]]; then
    local backup="$tgt.backup.$(stamp)"
    warn "$(tilde "$tgt") exists and is not ours -- moving it to $(tilde "$backup")"
    run mv "$tgt" "$backup"
  fi

  run mkdir -p "$(dirname "$tgt")"
  run ln -sfn "$src" "$tgt"
  ok "$(tilde "$tgt") -> ${src#"$DOTFILES"/}"
}

# link_package <path to a pkg/ subdirectory>
link_package() {
  local pkgdir=$1 d f rel

  # Whole-tree links first; the file walk below then skips their contents.
  for d in "${DIR_LINKS[@]}"; do
    [[ -d "$pkgdir/$d" ]] && link_one "$pkgdir/$d" "$HOME/$d"
  done

  while IFS= read -r -d '' f; do
    rel=${f#"$pkgdir"/}
    _is_under_dir_link "$rel" && continue
    link_one "$f" "$HOME/$rel"
  done < <(find "$pkgdir" -type f -print0)
}

link_all() {
  local p
  for p in "$DOTFILES"/pkg/*/; do
    [[ -d $p ]] || continue
    link_package "${p%/}"
  done
}
