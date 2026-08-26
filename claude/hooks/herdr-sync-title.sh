#!/bin/bash
# Mirror the Claude session's /rename title -> herdr agent name (so it shows in the
# herdr agents panel). Registered on Stop + UserPromptSubmit. Cheap: one grep over
# the transcript + a cached conditional, so herdr is only called when the title changes.
set -eu

[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v herdr >/dev/null 2>&1 || exit 0

input="$(cat)"
transcript="$(printf '%s' "$input" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("transcript_path",""))' 2>/dev/null || true)"
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# Latest "/rename" title = the last top-level `customTitle` in the transcript.
# Read it structurally (top-level JSON key), NOT by grepping text: the phrase and
# even the field name appear inside message content (prose/scripts) and would
# mis-extract. A pollution line has customTitle nested in .message, not top-level.
title="$(python3 - "$transcript" <<'PY' 2>/dev/null || true
import sys, json
t = ""
try:
    with open(sys.argv[1], encoding="utf-8", errors="replace") as f:
        lines = f.readlines()
    for line in reversed(lines):            # newest first — stop at the latest customTitle
        if '"customTitle"' not in line:      # cheap prefilter before JSON parse
            continue
        try: d = json.loads(line)
        except Exception: continue
        v = d.get("customTitle")
        if isinstance(v, str) and v:
            t = v
            break
    print(t)
except Exception:
    pass
PY
)"
[ -n "$title" ] || exit 0

# Skip the herdr call if the title hasn't changed since last sync (per pane).
cache="${TMPDIR:-/tmp}/herdr-title-${HERDR_PANE_ID//[:\/]/_}"
if [ -f "$cache" ] && [ "$(cat "$cache" 2>/dev/null || true)" = "$title" ]; then
  exit 0
fi

herdr agent rename "$HERDR_PANE_ID" "$title" >/dev/null 2>&1 || true
printf '%s' "$title" >"$cache" 2>/dev/null || true
exit 0
