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
oh-my-zsh, bash, tmux, git, readline and asdf. asdf comes from the AUR, so
only a workstation gets the binary: containers skip the AUR entirely (`makepkg`
refuses to run as root) and the apt list has no asdf either. Its config is
linked everywhere regardless.

## Usage

```sh
./setup.sh              # run every step
./setup.sh --dry-run    # print what would change, touch nothing
./setup.sh --list       # list the steps
./setup.sh --only 40    # run just the symlink step
./setup.sh --profile container   # force the container step set
```

## Layout

```
setup.sh          Orchestrator. Runs each install/ step in order; does no work itself.
install.sh        Entry point for Codespaces and devcontainers -> setup.sh --profile container.
lib/              common.sh (log/ok/skip/warn/die, have, as_root, run, stamp),
                  detect.sh (profile, package manager) and link.sh (the farm).
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
| `35-history` | Moves shell and REPL history into `$XDG_STATE_HOME` |
| `40-link` | Symlinks every package in `pkg/` into `$HOME` |
| `50-nvim` | Restores the pinned plugin set, then builds the Treesitter parsers |
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
psql, mysql, sqlite, redis, node and python.

History is data, not cache — pointing a variable at a new path does not move
the file, and a shell that starts empty looks exactly like a shell that lost
its history. `35-history` moves the files that already exist. Where both an
old and a new one are there it reports and leaves both alone: two history
files can overlap, and concatenating them blindly duplicates whatever does.
Caches like `zcompdump` are left to regenerate, which is what they are for.
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

`dcup` and `dcexec` are shell functions from `shell/functions.sh`, so they
exist once this repo's shell config is in place — before that, whatever `dcup`
your old rc file defines is the one that runs.

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
colourscheme washed out. It forwards whatever the host has, so a terminal whose
terminfo entry the image lacks — `alacritty` and `ghostty` are not in Debian's
ncurses — wants `TERM=xterm-256color dcexec …` instead.

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

A mount can only be set when a container is created, so a container that came
up before any of this has no `/dotfiles` and cannot gain one. `dcup` detects
that and tells you to recreate it with `dcup --remove-existing-container`.

## Requirements

Arch Linux or a Debian/Ubuntu container. `sudo` only if you are not root, and
an SSH key in `~/.ssh` if you clone over SSH.

## Gotchas

- **Never run a bare `tmux kill-server`.** It hits whatever server is already
  running, which is somebody's live sessions. Give it its own socket instead:
  `tmux -L test -f <conf> new-session -d && tmux -L test kill-server`.
- **A fresh Arch image has an empty pacman sync database**, so `pacman -S`
  resolves nothing. `10-packages` runs a full `-Syu` when the database is
  missing — `-Sy` on its own is the partial-upgrade footgun.
- **nvim-treesitter tracks its `main` branch**, which shells out to the
  `tree-sitter` CLI and installs asynchronously. A plain headless `+qa` exits
  before a single parser is built, which is why `50-nvim` drives
  `lib/nvim-treesitter-sync.lua` and waits on it.

## What is left

### CI

Nothing here is tested automatically, and the case for fixing that is
empirical: this restructure shipped three bugs that only showed up in a clean
environment, and one of them was called verified before it was.

1. `.github/workflows/ci.yml`, on push and on a weekly `schedule`.
2. **Lint**: `shellcheck -x` over `setup.sh install.sh lib/*.sh install/*.sh
   shell/*.sh`, plus `shfmt -d`. shellcheck on its own would have caught the
   dangling `&& \` that left package installation dead for months. The files
   in `shell/` are sourced rather than executed, so they carry no shebang —
   pass `-s bash` for those or every one of them fails SC2148.
3. **Arch job**: `container: archlinux`, run `./setup.sh`, then assert: exit 0,
   the 8 symlinks resolve, `nvim --headless +q` exits 0, `zsh -ic exit` exits
   0, and more than 15 parser `.so` files exist.
4. **Debian job**: `container: debian:stable-slim`, run `./install.sh`, the
   same assertions plus `nvim` >= 0.11, which is what proves `15-nvim-release`
   fired.
5. **Idempotency**: run the bootstrap twice and fail if the second run emits a
   single `ok` line from `40-link`.

Assert on artifacts — files exist, binaries run — never on an error string
being absent from a log, and never filter that log down to the script's own
log prefixes. That is exactly how a Treesitter failure stayed hidden through a
phase that had been declared verified.

### Ideas, not decisions

- **mise instead of asdf.** asdf works, but mise reads the same
  `.tool-versions`, is one binary with no shims, and covers env vars and tasks
  as well. Would also mean handling `ASDF_DATA_DIR`.
- **tmux.** `default-terminal "tmux-256color"` and `terminal-features ":RGB"`
  for truecolour and undercurl. Also `bind-key a send-keys C-b` looks like it
  was meant to be `send-prefix`.
- **A cache volume for devcontainers.** `dcup` pays for the package install
  and the parser build in every new container. A named volume holding
  `~/.local/share/nvim` and the oh-my-zsh clone would make every container
  after the first nearly free. Deferred on purpose: a parser `.so` is compiled
  against the image's glibc, so one volume shared across image families would
  hand a bookworm-built parser to an Alpine container. The volume name has to
  be scoped per family first.
- **`setup.sh --check`** — a doctor that reports drift between `$HOME` and the
  repo (broken symlinks, missing packages, a real file where a link belongs)
  without changing anything.

### Undecided

- **`pkg/nvim/.config/nvim/lua/kickstart/plugins/`** — five files (autopairs,
  debug, indent_line, lint, mini) that `init.lua` never imports. While they
  stay unimported, `vim.o.showmode = false` runs with no statusline to show
  the mode, and `nvim-lint` is configured but never runs. Either add
  `{ import = "kickstart.plugins" }` to the lazy spec or delete the directory.
- **`pkg/nvim/.config/nvim/.tool-versions`** — pins lua/python/php/julia inside
  the Neovim config directory. Looks like a stray `asdf set`; nothing there
  needs PHP or Julia.
- **`~/.docker`, `~/.aws`, `~/.cargo`, `~/.asdf`** — could follow XDG, but they
  hold credentials or installed runtimes. That is a data migration with a real
  `mv`, not a config change.
