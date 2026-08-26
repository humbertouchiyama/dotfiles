#!/usr/bin/env bash
# Symlink this repo's files into place. Idempotent, and never destroys an
# existing real file: anything in the way is moved to <target>.bak first.
#
#   ./install.sh          link everything
#   ./install.sh --dry    show what would happen, change nothing
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0
[[ "${1:-}" == "--dry" ]] && DRY=1

# repo-relative source : $HOME-relative target
MANIFEST=(
  "zsh/zshrc:.zshrc"
  "zsh/zshenv:.zshenv"
  "zsh/zprofile:.zprofile"
  "git/gitconfig:.gitconfig"
  "ghostty/config:.config/ghostty/config"
  "ghostty/init-sessions.sh:.config/ghostty/init-sessions.sh"
  "herdr/config.toml:.config/herdr/config.toml"
  "claude/statusline.sh:.claude/statusline.sh"
  "claude/hooks/herdr-sync-title.sh:.claude/hooks/herdr-sync-title.sh"
  "claude/output-styles/SR.md:.claude/output-styles/SR.md"
  "claude/output-styles/ELI5.md:.claude/output-styles/ELI5.md"
)

link() {
  local src="$REPO/$1" dst="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    printf '  MISSING  %-46s (not in repo)\n' "$2"
    return
  fi

  # Already pointing where we want it.
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    printf '  ok       %s\n' "$2"
    return
  fi

  # A real file or a foreign symlink is in the way — preserve it.
  if [[ -e "$dst" || -L "$dst" ]]; then
    if (( DRY )); then
      printf '  BACKUP   %-46s -> %s.bak\n' "$2" "$2"
    else
      mv "$dst" "$dst.bak"
      printf '  backed up %s -> %s.bak\n' "$2" "$2"
    fi
  fi

  if (( DRY )); then
    printf '  LINK     %-46s -> %s\n' "$2" "$1"
  else
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    printf '  linked   %-46s -> %s\n' "$2" "$1"
  fi
}

(( DRY )) && echo "dry run — nothing will change" || echo "installing from $REPO"
for entry in "${MANIFEST[@]}"; do
  link "${entry%%:*}" "${entry#*:}"
done

cat <<'NOTE'

Done. Two things this script cannot do for you:

  1. ~/.config/ghostty/config hardcodes an absolute path in `initial-command`.
     Ghostty does not expand ~ or $HOME there. Edit that line to match this
     machine's username before Ghostty will start herdr at login.

  2. The herdr Claude integration hook (herdr-agent-state.sh) is managed by
     herdr and is deliberately NOT in this repo. Install it with:
         herdr integration install claude
NOTE
