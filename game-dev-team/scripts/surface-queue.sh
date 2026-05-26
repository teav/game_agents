#!/bin/bash
# surface-queue.sh
#
# SessionStart hook for the game-dev-team plugin.
# Reports current phase, pending review queue depth, and recent migration ledger growth.
# Helps Claude prioritize what to address at session start.
#
# Non-blocking: always exits 0.

set -eu

# Find docs/game/ by walking up from PWD.
PROJECT_DIR=""
CUR="$PWD"
while [ "$CUR" != "/" ]; do
  if [ -d "$CUR/docs/game" ]; then
    PROJECT_DIR="$CUR"
    break
  fi
  CUR="$(dirname "$CUR")"
done

if [ -z "$PROJECT_DIR" ]; then
  exit 0
fi

# Check if jq is available. The other hooks (queue-review.sh, log-invocation.sh)
# depend on it and silently no-op if it's missing — which makes hook failure invisible.
# Warn loudly here at session start so the user can install it.
if ! command -v jq >/dev/null 2>&1; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "⚠️ game-dev-team: \`jq\` is not installed. The PostToolUse and SubagentStart hooks require it and will silently no-op. Install with \`apt-get install jq\` (Debian/Ubuntu) or \`brew install jq\` (macOS). Until then, the review queue will not be populated and agent invocations will not be logged."
  }
}
EOF
  exit 0
fi

# Read current phase (if phase.md exists)
PHASE="unknown"
PHASE_FILE="$PROJECT_DIR/docs/game/phase.md"
if [ -f "$PHASE_FILE" ]; then
  PHASE_LINE="$(grep -i '^Current phase:' "$PHASE_FILE" 2>/dev/null | head -1)"
  if [ -n "$PHASE_LINE" ]; then
    PHASE="$(echo "$PHASE_LINE" | sed 's/^[Cc]urrent phase:[[:space:]]*//' | tr -d '\r' | xargs)"
  fi
fi

QUEUE_FILE="$PROJECT_DIR/docs/game/.review-queue.jsonl"
LEDGER_DIR="$PROJECT_DIR/docs/game/migration-ledger"

PENDING_COUNT=0
OLDEST_PENDING=""
if [ -f "$QUEUE_FILE" ]; then
  PENDING_COUNT="$(grep '"status":"pending"' "$QUEUE_FILE" 2>/dev/null | wc -l | tr -d " ")"
  if [ "$PENDING_COUNT" -gt 0 ]; then
    OLDEST_PENDING="$(grep '"status":"pending"' "$QUEUE_FILE" | head -1)"
  fi
fi

LEDGER_RECENT=0
if [ -d "$LEDGER_DIR" ]; then
  LEDGER_RECENT="$(find "$LEDGER_DIR" -type f -mtime -7 2>/dev/null | wc -l | tr -d ' ')"
fi

# Always emit phase, plus anything else worth surfacing.
MESSAGE="📋 game-dev-team session start. Current phase: ${PHASE}."

if [ "$PENDING_COUNT" -gt 0 ]; then
  MESSAGE="$MESSAGE Review queue has ${PENDING_COUNT} pending entries."
  if [ -n "$OLDEST_PENDING" ] && command -v jq >/dev/null 2>&1; then
    OLDEST_FILE="$(echo "$OLDEST_PENDING" | jq -r '.file // empty')"
    if [ -n "$OLDEST_FILE" ]; then
      MESSAGE="$MESSAGE Oldest: ${OLDEST_FILE}."
    fi
  fi
fi

if [ "$LEDGER_RECENT" -gt 0 ]; then
  MESSAGE="$MESSAGE Migration ledger had ${LEDGER_RECENT} entries this week."
fi

MESSAGE="$MESSAGE Run /game-dev-team:doctor for a full report."

# JSON-escape the message.
if command -v jq >/dev/null 2>&1; then
  ESCAPED="$(printf '%s' "$MESSAGE" | jq -Rs .)"
else
  ESCAPED="\"$MESSAGE\""
fi

cat <<HEREDOC
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${ESCAPED}
  }
}
HEREDOC

exit 0
