# Functions shared by bash and zsh.

# Bring up the devcontainer for the current workspace, wiring in the host's git
# identity, Claude config and ssh-agent so the container can push and sign as you.
dcup() {
  local src="$HOME/.gitconfig"
  [ -f "$src" ] || src="${XDG_CONFIG_HOME:-$HOME/.config}/git/config"

  devcontainer up --workspace-folder . \
    --mount "type=bind,source=$src,target=/etc/gitconfig" \
    --mount "type=bind,source=$HOME/.claude,target=/var/lib/claude-code" \
    --mount "type=bind,source=$HOME/.claude.json,target=/var/lib/claude-code/.claude.json" \
    --remote-env "CLAUDE_CONFIG_DIR=/var/lib/claude-code" \
    --mount "type=bind,source=$SSH_AUTH_SOCK,target=/run/ssh-agent.sock" \
    --remote-env "SSH_AUTH_SOCK=/run/ssh-agent.sock" \
    "$@"
}

# Run a command inside the devcontainer dcup started.
dcexec() {
  devcontainer exec --workspace-folder . \
    --remote-env "SSH_AUTH_SOCK=/run/ssh-agent.sock" \
    --remote-env "CLAUDE_CONFIG_DIR=/var/lib/claude-code" \
    "$@"
}
