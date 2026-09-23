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
| `10-packages` | `pacman -S --needed` everything in `packages/base.txt` |
| `20-aur` | Bootstraps paru, installs `packages/aur.txt` |
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

## Requirements

Arch Linux, `sudo`, and an SSH key in `~/.ssh` if you clone over SSH.

Containers are not supported yet: `20-aur` skips itself as root because
`makepkg` refuses to run there, and `10-packages` skips any system without
pacman, but there is no Debian path and no `install.sh` entrypoint. That is
phase 3.
