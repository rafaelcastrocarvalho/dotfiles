#!/usr/bin/env bash
#
# Work out what kind of machine this is.
#
# Two axes, deliberately separate:
#
#   profile  -- what kind of box: workstation or container. Decides which
#               STEPS run (no AUR build as root, no chsh in a container).
#   manager  -- pacman or apt. Decides which PACKAGE LIST is used.
#
# They are independent: an Arch container uses the pacman list but still skips
# the AUR, and that falls out of the model instead of needing a special case.

detect_profile() {
  # An explicit choice always wins.
  if [[ -n ${PROFILE:-} ]]; then
    printf '%s' "$PROFILE"
    return
  fi

  if [[ -f /.dockerenv ]] ||
    [[ -f /run/.containerenv ]] ||       # podman
    [[ -n ${REMOTE_CONTAINERS:-} ]] ||   # VS Code Dev Containers
    [[ -n ${CODESPACES:-} ]] ||          # GitHub Codespaces
    [[ -n ${DEVCONTAINER:-} ]]; then
    printf 'container'
    return
  fi

  printf 'workstation'
}

detect_manager() {
  if have pacman; then
    printf 'pacman'
  elif have apt-get; then
    printf 'apt'
  else
    printf 'none'
  fi
}

# Path to a package list for the active manager, or empty if there is none.
package_list() {
  local name=$1 path="$DOTFILES/packages/$(detect_manager)/$1.txt"
  [[ -f $path ]] && printf '%s' "$path"
}
