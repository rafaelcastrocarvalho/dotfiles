#!/usr/bin/env bash
#
# Shared helpers. Sourced by setup.sh and by every script under install/.

# Colour only when stdout is a terminal, so logs stay readable when piped.
if [[ -t 1 ]]; then
  _c_reset=$'\033[0m'
  _c_blue=$'\033[34m'
  _c_green=$'\033[32m'
  _c_yellow=$'\033[33m'
  _c_red=$'\033[31m'
  _c_dim=$'\033[2m'
else
  _c_reset='' _c_blue='' _c_green='' _c_yellow='' _c_red='' _c_dim=''
fi

log()  { printf '%s==>%s %s\n'   "$_c_blue"   "$_c_reset" "$*"; }
ok()   { printf '%s  ok%s %s\n'  "$_c_green"  "$_c_reset" "$*"; }
skip() { printf '%s  --%s %s\n'  "$_c_dim"    "$_c_reset" "$*"; }
warn() { printf '%s  !!%s %s\n'  "$_c_yellow" "$_c_reset" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$_c_red"   "$_c_reset" "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Print $HOME-relative paths as ~/... so log lines stay short.
tilde() { printf '%s' "${1/#$HOME/\~}"; }

# Run a command, or describe it when DRY_RUN=1.
run() {
  if [[ ${DRY_RUN:-0} == 1 ]]; then
    printf '%s  would run:%s %s\n' "$_c_dim" "$_c_reset" "$*"
  else
    "$@"
  fi
}

# Timestamp used to name backups of files we displace.
stamp() { date +%Y%m%d%H%M%S; }
