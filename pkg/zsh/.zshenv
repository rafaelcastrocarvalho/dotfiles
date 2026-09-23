# Linked to ~/.zshenv by install/40-link.sh.
#
# This is the one zsh file that cannot move: zsh reads ~/.zshenv before ZDOTDIR
# exists, so this is where ZDOTDIR gets set and everything else follows it into
# ~/.config/zsh. Keep it tiny -- it runs for every zsh, scripts included.

# Resolve the repo through this file's own symlink. %N is the path of the
# running script; :A resolves symlinks, and three :h strip .zshenv -> zsh -> pkg.
export DOTFILES=${${(%):-%N}:A:h:h:h}

export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
