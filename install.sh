#!/bin/bash
#
# Entry point for VS Code Dev Containers and GitHub Codespaces.
#
# Both clone a dotfiles repo into the container and then run a script by one of
# a few well-known names, `install.sh` among them. Point them here with:
#
#   // devcontainer.json
#   "dotfiles": {
#     "repository": "https://github.com/<you>/dotfiles",
#     "installCommand": "install.sh"
#   }
#
# Everything this does lives in setup.sh; this only picks the container profile
# so no step tries to build from the AUR or change your login shell.

set -euo pipefail

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup.sh" --profile container "$@"
