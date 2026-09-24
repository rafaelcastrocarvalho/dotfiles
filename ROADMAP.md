# Roadmap

State of the restructure and what is left. `README.md` documents how the repo
works; this is only what is *not done yet*, plus the context needed to pick it
up cold.

## Where things stand

Branch `refactor/dotfiles-redesign`, 10 commits ahead of `master`, not merged:

```
481a798  feat: devcontainers get the host's config, not a bare image
3d7f076  docs: correct the tmux caveat in ROADMAP
e97f842  docs: add ROADMAP with the remaining phases
55bc5f9  chore(nvim): bump lazy.nvim
edc1924  fix: make the container bootstrap actually reach a working editor
2f7508d  feat: support containers and devcontainers          phase 3
ac11ddf  refactor: restructure into a symlink farm + XDG     phase 2
f089ece  refactor: drop vim, spacemacs and ubuntu legacy     phase 1
80d66b5  chore(nvim): update lazy-lock.json
d961d64  fix: repair broken bootstrap, sync zshrc            phase 0
```

266 tracked files became 56. Phases 0-3 are done and verified, and `481a798`
builds on them: a devcontainer now gets the host's config through a bind-mount
instead of a clone, `dcup` refuses to fail quietly, and a container prompt
carries an orange badge naming the project.

The author's machine has **not** been migrated yet — see `MIGRATION.md`. Until
it is, the `dcup` that actually runs is the old one defined inline in the live
`~/.zshrc`, so none of the devcontainer work is in effect on the host.

## Architecture in one screen

```
setup.sh          orchestrator: --dry-run --only --list --profile; runs
                  install/*.sh in order, each in its own process with set -e
install.sh        devcontainer/Codespaces entry -> setup.sh --profile container
lib/common.sh     log/ok/skip/warn/die, have(), as_root(), run() (DRY_RUN), stamp()
lib/detect.sh     detect_profile(), detect_manager(), package_list()
lib/link.sh       symlink farm; DIR_LINKS=(".config/nvim") links whole trees
lib/nvim-treesitter-sync.lua   headless parser build, reads langs from lazy spec
install/          10-packages 15-nvim-release 20-aur 30-shell 40-link
                  50-nvim 60-identity
packages/         pacman/{base,aur}.txt · apt/base.txt
pkg/<tool>/       mirrors $HOME (GNU stow layout)
shell/            env.sh aliases.sh functions.sh — sourced by bash AND zsh
```

Two orthogonal axes: **profile** (`workstation`/`container`) picks which steps
run; **manager** (`pacman`/`apt`) picks which package list is used.

Invariants worth not breaking:

- Nothing is ever copied or appended into `$HOME` — only symlinks.
- Every step is idempotent; a second run must report only `--` lines.
- The linker never deletes: it moves conflicts to `<file>.backup.<timestamp>`.
- Identity and machine-specific values live in untracked `*.local` files.
- `~/.bashrc` and `~/.zshenv` are the only two files that must stay in `$HOME`.

## Phase 4 — CI (highest value remaining)

The argument is empirical: this restructure shipped three bugs that only
appeared when someone ran it in a clean environment, and one of them was
declared verified before it was. CI converts that from "someone tripped over
it" to "the build went red".

1. `.github/workflows/ci.yml`, on push and weekly `schedule`.
2. **Lint job**: `shellcheck -x` over `setup.sh install.sh lib/*.sh
   install/*.sh shell/*.sh`, plus `shfmt -d`. shellcheck alone would have
   caught the dangling `&& \` that left package installation dead for months.
   `shell/*.sh` are sourced, not executed, so they have no shebang: pass
   `-s bash` for those or every one of them fails SC2148.
3. **Arch job**: `container: archlinux`, run `./setup.sh`, then assert —
   exit 0; the 8 symlinks resolve; `nvim --headless +q` exits 0;
   `zsh -ic exit` exits 0; parser `.so` count > 15.
4. **Debian job**: `container: debian:stable-slim`, run `./install.sh`, same
   assertions, plus that nvim is >= 0.11 (proves `15-nvim-release` fired).
5. **Idempotency**: run the bootstrap twice in each job and fail if the second
   run emits any `ok` line from `40-link` — every line must be `--`.

Assert on artifacts (files exist, binaries run), never on the absence of an
error string in the log. Do not filter the log to your own log prefixes; that
is exactly how the treesitter failure hid.

## Phase 5 — optional

- **mise instead of asdf.** asdf 0.20 works, but mise reads the existing
  `.tool-versions`, is one binary, needs no shims, and also does env vars and
  tasks. Touching this means also handling `ASDF_DATA_DIR` (see below).
- **tmux modernisation.** `default-terminal "tmux-256color"` plus
  `terminal-features ":RGB"` for truecolor and undercurl. Also
  `bind-key a send-keys C-b` looks like it was meant to be `send-prefix`.
- **A cache volume for devcontainers.** `dcup` runs the full bootstrap in every
  new container, so the apt install and the parser build are paid again each
  time. A named volume at a fixed path (`/var/lib/dotfiles-cache`) holding
  `~/.local/share/nvim` and the oh-my-zsh clone would make the second container
  onwards nearly free. Deferred on purpose: a Treesitter parser `.so` is
  compiled against the image's glibc, so one volume shared across image
  families would hand a bookworm-built parser to an Alpine container. It needs
  the volume name scoped per family before it is safe.
- **`setup.sh --check`** — a doctor that reports drift between `$HOME` and the
  repo (broken symlinks, missing packages, a file where a link belongs)
  without changing anything.

## Open decisions (not mine to make)

- **`pkg/nvim/.config/nvim/lua/kickstart/plugins/`** — five files (autopairs,
  debug, indent_line, lint, mini) that `init.lua` never imports, deferred
  pending a per-plugin review. While they stay unimported,
  `vim.o.showmode = false` runs with no statusline to show the mode, and
  `nvim-lint` is configured but never runs. Either add
  `{ import = "kickstart.plugins" }` to the lazy spec or delete the directory.
- **`pkg/nvim/.config/nvim/.tool-versions`** — pins lua/python/php/julia inside
  the Neovim config dir. Looks like a stray `asdf set`; nothing there needs
  PHP or Julia.
- **`~/.docker`, `~/.aws`, `~/.cargo`, `~/.asdf`** — could follow XDG, but they
  hold credentials or installed runtimes. Moving them is a data migration, not
  a config change, and needs its own step with an actual `mv`.
- **Merging to `master`** — still on the branch.

## Environment gotchas

- **Never run a bare `tmux kill-server`.** It hits whatever server is already
  running, which is somebody's live sessions. Always use a dedicated socket:
  `tmux -L test -f <conf> new-session -d && tmux -L test kill-server`.
- **Debian stable ships Neovim 0.10**, this config needs 0.11
  (`vim.hl.on_yank`). `15-nvim-release` handles it.
- **A fresh Arch image has an empty pacman sync database.** `pacman -S` finds
  nothing; `10-packages` does a full `-Syu` when the database is missing,
  because `-Sy` alone is the partial-upgrade footgun.
- **nvim-treesitter's `main` branch needs the `tree-sitter` CLI** to build
  parsers, and its `install()` is async — a plain headless `+qa` exits before
  anything is built.
- **`devcontainer exec` starts the shell with `TERM=xterm`**, whose terminfo
  claims 8 colours. zsh checks terminfo and silently drops any 256-colour
  prompt escape; bash never checks, which is why the same prompt badge worked
  in one shell and not the other. Neovim renders washed out for the same
  reason. `dcexec` forwards `TERM` and `COLORTERM`, and the badge is written
  with raw escapes rather than `%K{208}`.
