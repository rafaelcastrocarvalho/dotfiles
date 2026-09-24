# Migration runbook

One-time checklist for moving this machine onto the restructured repo. Delete
this file once it is done — `README.md` is the lasting documentation.

Nothing here destroys anything. Every file the setup displaces is moved to
`<file>.backup.<timestamp>`, never deleted, so every step is reversible.

---

## 1. Read the plan

```sh
cd ~/dev/personal/dotfiles
./setup.sh --dry-run
```

Changes nothing. Read the output and confirm it matches the table in step 3.

## 2. Run it

```sh
./setup.sh
```

It will ask for your sudo password (step 10, `pacman`). Nothing else should
prompt: paru and asdf-vm are already installed, and zsh is already your login
shell, so `chsh` is skipped.

Expect `60-identity` to say it is moving `~/.gitconfig` aside. That is intended
— it reads your name and email out of it first and writes them to
`~/.config/git/config.local`.

## 3. What the run does to `$HOME`

Handled automatically:

| Path | What happens |
| --- | --- |
| `~/.zshrc` | Backed up. `ZDOTDIR` makes it dead, so it must not stay. |
| `~/.bashrc` | Backed up, replaced by a symlink. |
| `~/.gitconfig` | Identity copied to `config.local`, then backed up. |
| `~/.oh-my-zsh` | Moved to `~/.local/share/oh-my-zsh` (moved, not re-cloned, so custom plugins survive). |
| `~/.config/nvim` | Already correct — skipped. |

Your current `~/.zshrc` defines `dcup` and `dcexec` inline, so backing it up
hands both over to the repo's versions in `shell/functions.sh`. They do more
than the old ones: they bind-mount this repo into the container at `/dotfiles`,
run the bootstrap there, and forward `TERM`/`COLORTERM`. The first `dcup` in a
project therefore takes minutes rather than seconds. Containers that already
exist were created without the mount and cannot gain it — recreate them with
`dcup --remove-existing-container`.

Created:

```
~/.zshenv                      ~/.config/asdf/asdfrc
~/.config/zsh/.zshrc           ~/.config/readline/inputrc
~/.config/git/config           ~/.config/tmux/tmux.conf
~/.config/git/config.local     (generated, not tracked)
```

## 4. Post-setup cleanup

These four are left behind on purpose: they stopped being link targets, so the
linker no longer manages them and will not touch them. Remove them yourself,
**after** confirming step 5 passes.

```sh
rm ~/.tmux.conf     # stopgap symlink; the real one is ~/.config/tmux/tmux.conf
rm ~/.inputrc       # stopgap symlink; INPUTRC now points at ~/.config/readline/
rm ~/.asdfrc        # superseded by ASDF_CONFIG_FILE -> ~/.config/asdf/asdfrc
rm ~/.spacemacs     # dangling since spacemacs was dropped
```

Optional, once you trust the new setup — the backups the run created:

```sh
ls -d ~/.zshrc.backup.* ~/.bashrc.backup.* ~/.gitconfig.backup.* 2>/dev/null
```

(Scoped on purpose — a bare `find ~ -name '*.backup.*'` also turns up unrelated
backups such as `~/.claude/backups/`.)

## 5. Verify

Open a **new terminal** first — the current one still has the old environment.

```sh
# Shell config resolves through the repo
echo $DOTFILES                 # -> /home/rafael/dev/personal/dotfiles
echo $ZDOTDIR                  # -> ~/.config/zsh
type dcup                      # -> function
glog -1                        # -> the alias works
echo "[$DOTFILES_CONTAINER]"   # -> [] — the prompt badge is containers only

# Config landed in XDG paths
echo $ASDF_CONFIG_FILE         # -> ~/.config/asdf/asdfrc
asdf info | grep CONFIG_FILE   # -> same path
bind -v | grep editing-mode    # bash: -> set editing-mode vi

# Identity survived the ~/.gitconfig move
git config --get user.email    # -> rafael.c.carvalho@gmail.com
git config --get core.editor   # -> nvim

# Editor and multiplexer
nvim --headless +q && echo nvim ok
tmux -L check -f ~/.config/tmux/tmux.conf new-session -d && \
  tmux -L check kill-server && echo tmux ok
```

> The `-L check` above gives tmux its own socket. Never run a bare
> `tmux kill-server` — it kills the server your session is running in.

Then check `$HOME` got quieter:

```sh
ls -A ~ | grep -c '^\.'        # was 109
```

## 6. Rollback

Per file — the backups are plain files:

```sh
mv ~/.zshrc.backup.<timestamp> ~/.zshrc
mv ~/.gitconfig.backup.<timestamp> ~/.gitconfig
mv ~/.local/share/oh-my-zsh ~/.oh-my-zsh
```

The whole repo, back to before this work:

```sh
git checkout master
```

The branch `refactor/dotfiles-redesign` holds every phase; `master` is
untouched.

## 7. Still open

Not part of this migration, tracked so they do not get lost:

- **`lua/kickstart/plugins/`** — five files (autopairs, debug, indent_line,
  lint, mini) that `init.lua` never imports. Deferred pending your review of
  each plugin. While they stay unimported, `vim.o.showmode = false` runs with
  no statusline to show the mode.
- **`pkg/nvim/.config/nvim/.tool-versions`** — pins lua/python/php/julia inside
  the Neovim config directory. Looks like a stray `asdf set`; nothing in the
  config needs PHP or Julia.
- **`~/.docker`, `~/.aws`, `~/.cargo`, `~/.asdf`** — could follow XDG, but they
  hold credentials or installed runtimes. Moving them is a data migration, not
  a config change, and needs its own step.
- **Phase 4** — CI: shellcheck, plus a from-scratch Arch and Debian build that
  runs `setup.sh` and asserts the result. Phase 3 was verified by hand in a
  clean `debian:stable-slim` container; CI is what keeps it verified.

Phase 3 is done: `./install.sh` bootstraps a Debian container end to end,
including replacing Debian's Neovim 0.10 with the upstream build. On top of it,
`dcup` now gives a local devcontainer the same config as the host without
cloning anything. See the "Containers and devcontainers" section of
`README.md`.
