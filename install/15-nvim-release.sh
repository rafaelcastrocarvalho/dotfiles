#!/usr/bin/env bash
#
# Install Neovim from the official release when the packaged one is too old.
#
# This config needs 0.11 (vim.hl.on_yank, vim.lsp.protocol.Methods), and Debian
# 13 stable ships 0.10.4 -- so on apt systems the distro package alone leaves
# you with an editor that errors on startup. Arch tracks upstream closely and
# normally skips this entirely.

set -euo pipefail
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"

MIN_MINOR=11
PREFIX=/usr/local

log "Neovim version"

current=""
if have nvim; then
  current=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
fi

if [[ -n $current ]]; then
  major=${current%%.*}
  minor=${current#*.}
  minor=${minor%%.*}
  if [[ $major -gt 0 || $minor -ge $MIN_MINOR ]]; then
    skip "nvim $current is new enough"
    exit 0
  fi
  warn "nvim $current is older than 0.$MIN_MINOR -- installing the official build"
else
  log "nvim not found -- installing the official build"
fi

case "$(uname -m)" in
  x86_64) arch=x86_64 ;;
  aarch64 | arm64) arch=arm64 ;;
  *) die "no official Neovim build for $(uname -m); install it yourself" ;;
esac

url="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${arch}.tar.gz"

if [[ ${DRY_RUN:-0} == 1 ]]; then
  skip "would install $url into $PREFIX"
  exit 0
fi

have curl || die "curl is needed to download Neovim"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "$url" -o "$tmp/nvim.tar.gz"
tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"

# The tarball unpacks to nvim-linux-<arch>/{bin,lib,share}; --strip-components
# lands those directly in the prefix so nvim ends up on the default PATH.
as_root mkdir -p "$PREFIX"
as_root tar -xzf "$tmp/nvim.tar.gz" -C "$PREFIX" --strip-components=1

hash -r 2>/dev/null || true
ok "nvim $("$PREFIX/bin/nvim" --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') installed to $PREFIX"
