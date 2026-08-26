# dotfiles

Personal macOS config: zsh, Ghostty, herdr, git, and Claude Code.

Everything here is verified free of credentials. Anything that carries a
secret, or client infrastructure detail, lives in a separate private repo and
is listed under [What is deliberately not here](#what-is-deliberately-not-here).

## Install

```sh
git clone git@github.com:humbertouchiyama/dotfiles.git ~/dotfiles
cd ~/dotfiles
git config core.hooksPath githooks   # enable the secret guard
./install.sh --dry                   # preview
./install.sh
```

`install.sh` symlinks each file into `$HOME`. It is idempotent, and it never
destroys anything: an existing real file at a target path is moved to
`<target>.bak` before the link is made, and the move is reported.

## Contents

| Path | Links to | What it is |
|---|---|---|
| `zsh/zshrc` | `~/.zshrc` | oh-my-zsh, PATH (Flutter/Android/Java/Ruby/nvm/libpq), git aliases, `ports` and `killport` |
| `zsh/zshenv` | `~/.zshenv` | `name()` — renames the current herdr agent. Lives here, not in `.zshrc`, so it also loads in non-interactive shells |
| `zsh/zprofile` | `~/.zprofile` | `brew shellenv` |
| `git/gitconfig` | `~/.gitconfig` | identity, `gh` credential helper, rebase-on-pull, autoSetupRemote, git-lfs |
| `ghostty/config` | `~/.config/ghostty/config` | JetBrains Mono, Catppuccin Mocha, Warp-style keybinds, 100k scrollback, `initial-command` |
| `ghostty/init-sessions.sh` | `~/.config/ghostty/init-sessions.sh` | run by `initial-command` on the login-item launch; attaches the surface to the default herdr session, with a login-shell fallback so a failure can never leave you without a terminal |
| `herdr/config.toml` | `~/.config/herdr/config.toml` | `ctrl+z` prefix (ported from tmux), spatial `ijkl` pane swap, arrow-key pane focus, `pane_history` for scrollback across reboot |
| `claude/statusline.sh` | `~/.claude/statusline.sh` | Claude Code status line: model, branch, worktree, output style, context bar, session cost |
| `claude/hooks/herdr-sync-title.sh` | `~/.claude/hooks/herdr-sync-title.sh` | mirrors the Claude session's `/rename` title into the herdr agents panel |
| `claude/output-styles/SR.md` | `~/.claude/output-styles/SR.md` | terse, no-preamble output style |
| `claude/output-styles/ELI5.md` | `~/.claude/output-styles/ELI5.md` | plain-language output style |

## Two things `install.sh` cannot do

1. **Ghostty's `initial-command` needs an absolute path.** Ghostty does not
   expand `~` or `$HOME` there, so `ghostty/config` hardcodes
   `/Users/humbertocosta/...`. Edit that one line for a different machine.
   The absolute path is required for a second reason: a login-item app
   inherits launchd's `PATH`, which has no `/opt/homebrew`.

2. **The herdr Claude integration hook is not in this repo.**
   `~/.claude/hooks/herdr-agent-state.sh` is generated and overwritten by
   herdr, so versioning it would fight the tool. Install it with
   `herdr integration install claude`.

## Secret guard

`githooks/pre-commit` blocks any commit whose staged content matches a
credential shape (GitHub, OpenAI, Stripe, Sentry, Slack, AWS, Google API keys,
PEM private keys, Render resource ids, and URIs with inline passwords).

Enable it once per clone — git does not install hooks for you:

```sh
git config core.hooksPath githooks
```

It exists because a public repo is permanent. A secret pushed once is
compromised even if the next commit deletes it: unreferenced commits stay
reachable, and forks and scrapers do the rest. The guard's job is to stop a
secret from ever entering, not to clean one up afterwards.

## What is deliberately not here

Kept in a private repo:

- `~/.claude/settings.json` — its `autoMode.environment` block describes client
  infrastructure (org, cloud projects, hostnames, CI secret *names*).
- `~/.claude/CLAUDE.md` and `RTK.md` — personal instructions and private tooling.
- `~/.claude/projects/*/memory/` — per-project memory; references client
  infrastructure throughout.
- `~/.ssh/config` — host aliases and key *paths* (never keys).

Never committed to any repo: `~/.aws/credentials`, `~/.config/gcloud/`,
Firebase application default credentials, `~/.claude.json`,
`~/.config/gh/hosts.yml`, and everything under `~/.ssh/` except `config`.
