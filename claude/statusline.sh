#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "?"')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
STYLE=$(echo "$input" | jq -r '(.output_style.name? // .output_style? // "") | tostring' 2>/dev/null)

# Git branch
BRANCH=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
fi

# Worktree detection
WORKTREE=""
if [[ "$DIR" == *".claude/worktrees/"* ]]; then
    WORKTREE=$(echo "$DIR" | sed 's|.*\.claude/worktrees/||' | cut -d/ -f1)
fi

# Colors
G='\033[32m' Y='\033[33m' C='\033[36m' R='\033[31m' D='\033[2m' RST='\033[0m'

# Line 1: Model | Branch | Worktree
LINE1="${C}${MODEL}${RST}"
[ -n "$BRANCH" ] && LINE1="${LINE1}  ${G}${BRANCH}${RST}"
[ -n "$WORKTREE" ] && LINE1="${LINE1}  ${Y}wt:${WORKTREE}${RST}"
[ -n "$STYLE" ] && [ "$STYLE" != "null" ] && [ "$(echo "$STYLE" | tr A-Z a-z)" != "default" ] && LINE1="${LINE1}  ${D}style:${STYLE}${RST}"

# Line 2: Context bar + cost
FILLED=$((PCT / 5))
EMPTY=$((20 - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /=}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /-}"

if [ "$PCT" -ge 90 ]; then BC="$R"
elif [ "$PCT" -ge 70 ]; then BC="$Y"
else BC="$G"; fi

COST_FMT=$(printf '$%.2f' "$COST")
LINE2="${BC}[${BAR}]${RST} ${PCT}% ${D}|${RST} ${COST_FMT}"

echo -e "$LINE1"
echo -e "$LINE2"
