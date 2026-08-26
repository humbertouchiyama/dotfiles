#!/bin/zsh
# Ghostty `initial-command` — runs only on the first surface of a Ghostty
# launch (i.e. the login-item start), never on manual new windows/tabs.
# Attaches this surface to the "default" herdr session. The "personal" session
# is opened by hand (cmd+T, then `herdr --session personal`).
#
# ABSOLUTE PATH IS REQUIRED. A login-item app inherits launchd's PATH
# (/usr/bin:/bin:/usr/sbin:/sbin) — no /opt/homebrew — and this script is
# non-interactive + non-login, so neither .zprofile (brew shellenv) nor .zshrc
# is sourced. Bare `herdr` resolves to "command not found" at boot.
HERDR=/opt/homebrew/bin/herdr

# Fail-safe. wait-after-command defaults to false, so if this script dies the
# surface closes and Ghostty can quit leaving no window — and initial-command
# runs on EVERY Ghostty start, so that would repeat on each relaunch. Always
# land in a usable shell instead.
fallback() { exec /bin/zsh -l }
[ -x "$HERDR" ] || fallback

"$HERDR" || fallback
