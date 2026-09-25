# Functions shared by bash and zsh.

# Bring up the devcontainer for the current workspace and configure it like the
# host: the git identity, the ssh-agent, the Claude config and this repo, then
# the bootstrap itself.
#
# The devcontainer CLI, unlike the VS Code extension, copies no ~/.gitconfig and
# forwards no ssh-agent, so both are mounted by hand. Every mount is optional:
# whatever the host does not have is simply left out instead of failing.
dcup() {
  local gitconfig="$HOME/.gitconfig"
  [ -f "$gitconfig" ] || gitconfig="${XDG_CONFIG_HOME:-$HOME/.config}/git/config"

  # Names the badge that shell/env.sh puts in the container's prompt.
  local label="${PWD##*/}"

  local args=(--workspace-folder . --remote-env "DOTFILES_CONTAINER=$label")

  # 60-identity reads /etc/gitconfig before anything else.
  if [ -f "$gitconfig" ]; then
    args+=(--mount "type=bind,source=$gitconfig,target=/etc/gitconfig")

    # config.local holds the actual identity and is included by a relative
    # path, which git resolves against /etc once mounted there -- so it has
    # to land at /etc/config.local, not wherever it sits on the host.
    local gitconfig_local="$(dirname "$gitconfig")/config.local"
    if [ -f "$gitconfig_local" ]; then
      args+=(--mount "type=bind,source=$gitconfig_local,target=/etc/config.local")
    fi
  fi
  if [ -d "$HOME/.claude" ]; then
    args+=(--mount "type=bind,source=$HOME/.claude,target=/var/lib/claude-code")
    args+=(--remote-env "CLAUDE_CONFIG_DIR=/var/lib/claude-code")
  fi
  if [ -f "$HOME/.claude.json" ]; then
    args+=(--mount "type=bind,source=$HOME/.claude.json,target=/var/lib/claude-code/.claude.json")
  fi
  if [ -n "${SSH_AUTH_SOCK:-}" ]; then
    args+=(--mount "type=bind,source=$SSH_AUTH_SOCK,target=/run/ssh-agent.sock")
    args+=(--remote-env "SSH_AUTH_SOCK=/run/ssh-agent.sock")
  fi
  # Bind-mounted rather than cloned: the symlinks then point into the mount, so
  # editing a config on the host takes effect in the container immediately.
  if [ -n "${DOTFILES:-}" ]; then
    args+=(--mount "type=bind,source=$DOTFILES,target=/dotfiles")
  else
    # Saying nothing here is how you end up in a container with a bare Neovim
    # and no idea why.
    echo "dcup: \$DOTFILES is not set -- bringing the container up WITHOUT your dotfiles" >&2
  fi

  devcontainer up "${args[@]}" "$@" || return

  [ -n "${DOTFILES:-}" ] || return 0

  # Mounts are fixed when the container is created, so an existing container
  # that predates this has no /dotfiles and nothing to bootstrap from.
  if ! dcexec test -d /dotfiles 2>/dev/null; then
    echo "dcup: /dotfiles is not mounted in this container -- it was created without it." >&2
    echo "dcup: recreate it with: dcup --remove-existing-container" >&2
    return 1
  fi

  echo "dcup: running the dotfiles bootstrap inside the container..." >&2
  dcexec /dotfiles/setup.sh --profile container
}

# Run a command inside the devcontainer dcup started.
dcexec() {
  # --remote-env from `up` does not carry over to `exec`, so repeat it here.
  local args=(--workspace-folder .)
  args+=(--remote-env "SSH_AUTH_SOCK=/run/ssh-agent.sock")
  args+=(--remote-env "CLAUDE_CONFIG_DIR=/var/lib/claude-code")
  args+=(--remote-env "DOTFILES_CONTAINER=${PWD##*/}")

  # Left alone, `devcontainer exec` starts the shell with TERM=xterm, whose
  # terminfo advertises 8 colours -- Neovim's colourscheme and the prompt both
  # come out washed out. COLORTERM is what Neovim reads for 24-bit colour.
  args+=(--remote-env "TERM=${TERM:-xterm-256color}")
  if [ -n "${COLORTERM:-}" ]; then
    args+=(--remote-env "COLORTERM=$COLORTERM")
  fi

  devcontainer exec "${args[@]}" "$@"
}
