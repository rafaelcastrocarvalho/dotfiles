#!/usr/bin/env bash
#
# Link every package under pkg/ into $HOME.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"
# shellcheck source=../lib/link.sh
source "$DOTFILES/lib/link.sh"

log "Symlinks"
link_all
