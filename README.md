# dotfiles

Arch Linux development environment. Clone it, run `setup.sh`, get a configured
machine.

```sh
git clone git@github.com:<you>/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles
./setup.sh
```

Nothing is copied into `$HOME` — everything is symlinked back to this repo, so
editing a config here is editing the live config. Running `setup.sh` again is
how you apply updates; every step is a no-op when there is nothing to do.

## What it sets up

Neovim (kickstart-based, plugins pinned by `lazy-lock.json`), zsh with
oh-my-zsh, bash, tmux, git, readline and asdf.

## Usage

```sh
./setup.sh              # run every step
./setup.sh --dry-run    # print what would change, touch nothing
./setup.sh --list       # list the steps
./setup.sh --only 40    # run just the symlink step
```

## Layout

```
setup.sh          Orchestrator. Runs each install/ step in order; does no work itself.
lib/              common.sh (logging, dry-run) and link.sh (the symlink farm).
install/          Numbered, idempotent steps. Each runs standalone.
packages/         Package lists as data, one per line.
pkg/              The symlink farm. Each subdirectory mirrors $HOME.
shell/            env, aliases and functions sourced by BOTH bash and zsh.
```

`pkg/` follows the GNU stow convention: `pkg/tmux/.config/tmux/tmux.conf` is
linked to `~/.config/tmux/tmux.conf`. `stow -d pkg -t ~ tmux` would do the same
thing, so the layout is not tied to `lib/link.sh`.

The steps:

| Step | Does |
| --- | --- |
| `10-packages` | Installs `packages/<manager>/base.txt` via pacman or apt |
| `15-nvim-release` | Installs Neovim from upstream if the packaged one is < 0.11 |
| `20-aur` | Bootstraps paru, installs `packages/pacman/aur.txt` |
| `30-shell` | Installs oh-my-zsh, makes zsh the login shell |
| `40-link` | Symlinks every package in `pkg/` into `$HOME` |
| `50-nvim` | `nvim --headless "+Lazy! restore"` — restores the pinned plugin set |
| `60-identity` | Writes `~/.config/git/config.local` with your name and email |

## Adding a config

Put the file in `pkg/<name>/` at the path it should have relative to `$HOME`,
then run `./setup.sh --only 40`:

```sh
mkdir -p pkg/ghostty/.config/ghostty
mv ~/.config/ghostty/config pkg/ghostty/.config/ghostty/config
./setup.sh --only 40
```

Directories are linked file by file, so a new file needs a re-run. The
exception is `.config/nvim`, listed in `DIR_LINKS` in `lib/link.sh` and linked
whole — new Lua files there are picked up with no re-run.

## XDG, and the two files that cannot move

Config lives under `~/.config` wherever the tool allows it. Three tools needed
an environment variable to look there, all set in `shell/env.sh`:

| Tool | Variable | Config now at |
| --- | --- | --- |
| asdf | `ASDF_CONFIG_FILE` | `~/.config/asdf/asdfrc` |
| readline | `INPUTRC` | `~/.config/readline/inputrc` |
| zsh | `ZDOTDIR` (set in `~/.zshenv`) | `~/.config/zsh/.zshrc` |

readline has no XDG support of its own — verified on readline 8.3, a file at
`$XDG_CONFIG_HOME/readline/inputrc` is simply ignored — so `INPUTRC` is doing
the work, not the path.

Two files are stuck in `$HOME` and always will be: `~/.bashrc`, because bash
hardcodes it, and `~/.zshenv`, because zsh reads it before `ZDOTDIR` exists.

`shell/env.sh` also points history and cache files at `$XDG_STATE_HOME` and
`$XDG_CACHE_HOME` — shell history, `zcompdump`, and the REPL histories for
psql, mysql, sqlite, redis, node and python. Only files that regenerate
themselves are relocated, so nothing breaks if an old one is never migrated.
Config holding credentials (`~/.docker`, `~/.aws`) is deliberately left alone:
moving that is a data migration, not a config change.

## What is not tracked

Identity and anything machine-specific stays out of the repo, which is what
keeps a typo from propagating to every machine and lets this be public:

| File | Holds |
| --- | --- |
| `~/.config/git/config.local` | git `user.name` and `user.email` |
| `~/.config/zsh/.zshrc.local`, `~/.bashrc.local` | per-machine shell overrides |

Secrets are not in scope. SSH keys and cloud credentials belong to the
ssh-agent and your password manager — `dcup` already forwards `SSH_AUTH_SOCK`
into the container rather than mounting key material.

When `40-link` finds a real file where a symlink should go, it moves it to
`<file>.backup.<timestamp>` instead of deleting it.

## Containers and devcontainers

Two axes decide what happens, kept separate on purpose:

| | Values | Decides |
| --- | --- | --- |
| **profile** | `workstation`, `container` | which **steps** run |
| **manager** | `pacman`, `apt` | which **package list** is used |

They are independent, so an Arch container uses the pacman list and still skips
the AUR without needing a special case. The profile is detected from
`/.dockerenv`, `/run/.containerenv`, `$REMOTE_CONTAINERS`, `$CODESPACES` and
`$DEVCONTAINER`; `--profile` overrides it.

### A machine with nothing on it (Codespaces, a fresh VM)

`install.sh` is the entry point Codespaces and the Dev Containers extension
look for, and it runs `setup.sh --profile container`. With the devcontainer
CLI the equivalent is:

```bash
devcontainer up --workspace-folder . \
  --dotfiles-repository https://github.com/<you>/dotfiles \
  --dotfiles-install-command install.sh
```

### A devcontainer on your own machine (devcontainer CLI)

The repo is already on the host, so cloning it again only hides your local
edits. `dcup` bind-mounts it at `/dotfiles` and runs the bootstrap inside:

```bash
dcup          # devcontainer up, with the mounts, then setup.sh
dcexec zsh    # a shell in it
```

Because the symlinks point into the mount, editing a config on the host takes
effect in the container with no rebuild.

Shells inside the container wear an orange badge with the project name, so a
container prompt is never mistaken for the host one:

```
 frete-agil  ➜  app git:(main) ✗
```

`dcup` and `dcexec` set `DOTFILES_CONTAINER` for it. A container that came up
some other way still gets a badge, just the generic `container` — `shell/env.sh`
falls back to `/.dockerenv` and `/run/.containerenv`.

`dcexec` also forwards `TERM` and `COLORTERM`. Left alone, `devcontainer exec`
starts the shell with `TERM=xterm`, whose terminfo advertises 8 colours: zsh
then drops every 256-colour prompt escape it is given, and Neovim renders its
colourscheme washed out.

The CLI is not the VS Code extension: it copies no `~/.gitconfig` and forwards
no ssh-agent. `dcup` does both by hand, and skips any mount whose source the
host does not have. It passes extra arguments through, so `dcup --build-no-cache`
works.

The first `dcup` in a project pays for the package install and the parser
build. When the image already carries Neovim, zsh and the CLI tools, skip all
of that and only place the symlinks:

```bash
dcexec /dotfiles/setup.sh --only 40
```

### In the container profile

- The AUR is skipped — `makepkg` refuses to run as root by design.
- `chsh` is skipped; the change would not survive the image anyway. Use
  `dcexec zsh`.
- `sudo` is only used when not already root, so a root container with no sudo
  installed still works.
- Git identity is taken from `/etc/gitconfig` if something mounted it there
  (which is what `dcup` does), otherwise from `$GIT_AUTHOR_NAME` and
  `$GIT_AUTHOR_EMAIL`. It never blocks on a prompt.
- `build-essential` is dropped when the image already has `cc` and `c++`. It is
  the most expensive entry in the list, and Treesitter needs both compilers —
  several parsers ship a C++ scanner.
- `packages/apt/base.txt` is deliberately leaner: no docker, no postgresql
  server, nothing the image or host already provides.

Debian stable ships Neovim 0.10, and this config needs 0.11 (`vim.hl.on_yank`),
so `15-nvim-release` replaces it with the official build. On Arch it is a no-op.


## Requirements

Arch Linux or a Debian/Ubuntu container. `sudo` only if you are not root, and
an SSH key in `~/.ssh` if you clone over SSH.
