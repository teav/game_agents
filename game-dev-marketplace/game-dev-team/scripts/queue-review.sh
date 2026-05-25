#!/bin/bash
# queue-review.sh
#
# PostToolUse hook for the game-dev-team plugin.
#
# Two behaviors depending on the file path written:
#   1. Writes under docs/game/{design,spec,art,narrative,playtest,platform,perf}/
#      → append a pending entry to docs/game/.review-queue.jsonl
#   2. Writes under docs/game/reviews/<adversary>/
#      → read the new review file's based_on field, close matching pending queue entries
#
# Both behaviors emit hookSpecificOutput.additionalContext to inform Claude.
# Non-blocking: always exits 0.

set -eu

INPUT="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')"
TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // empty')"

# Only act on writes inside docs/game/.
case "$FILE_PATH" in
  */docs/game/*) ;;
  *) exit 0 ;;
esac

# Find the project's docs/game directory.
QUEUE_DIR=""
DIR="$(dirname "$FILE_PATH")"
while [ "$DIR" != "/" ] && [ "$DIR" != "." ]; do
  if [ -d "$DIR/docs/game" ]; then
    QUEUE_DIR="$DIR/docs/game"
    break
  fi
  case "$DIR" in
    */docs/game) QUEUE_DIR="$DIR"; break ;;
    */docs/game/*) DIR="$(dirname "$DIR")"; continue ;;
  esac
  DIR="$(dirname "$DIR")"
done

if [ -z "$QUEUE_DIR" ]; then
  exit 0
fi

QUEUE_FILE="$QUEUE_DIR/.review-queue.jsonl"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# ============================================================
# Path 1: Review file written by an adversary → close matching pending entries.
# ============================================================
case "$FILE_PATH" in
  */docs/game/reviews/*)
    if [ ! -f "$QUEUE_FILE" ]; then
      exit 0
    fi

    # Extract all docs/game/* file references from the review's YAML front-matter.
    # Awk: read up to (and including) the second "---" marker, then stop.
    # Grep: pull file path tokens. The pattern matches path-safe characters; the @version suffix
    # is naturally excluded because '@' is not in the character class.
    BASED_ON_FILES="$(awk 'BEGIN{i=0} /^---$/{i++; if (i==2) exit} {print}' "$FILE_PATH" 2>/dev/null \
      | grep -oE 'docs/game/[a-zA-Z0-9/_.-]+' \
      | sort -u || true)"

    if [ -z "$BASED_ON_FILES" ]; then
      exit 0
    fi

    # Update queue: change pending → addressed for matching files.
    TMP_QUEUE="$(mktemp)"
    CLOSED_COUNT=0

    while IFS= read -r line; do
      [ -z "$line" ] && continue
      CURRENT_FILE="$(echo "$line" | jq -r '.file // empty' 2>/dev/null || echo "")"
      CURRENT_STATUS="$(echo "$line" | jq -r '.status // empty' 2>/dev/null || echo "")"

      MATCHED=0
      if [ "$CURRENT_STATUS" = "pending" ]; then
        for target in $BASED_ON_FILES; do
          if [ "$CURRENT_FILE" = "$target" ]; then
            MATCHED=1
            break
          fi
        done
      fi

      if [ "$MATCHED" = "1" ]; then
        # shellcheck disable=SC2016
        UPDATED="$(echo "$line" | jq -c \
          --arg ts "$TIMESTAMP" \
          --arg by "$(basename "$(dirname "$FILE_PATH")")" \
          '.status = "addressed" | .closed_at = $ts | .closed_by = $by')"
        echo "$UPDATED" >> "$TMP_QUEUE"
        CLOSED_COUNT=$((CLOSED_COUNT + 1))
      else
        echo "$line" >> "$TMP_QUEUE"
      fi
    done < "$QUEUE_FILE"

    mv "$TMP_QUEUE" "$QUEUE_FILE"

    if [ "$CLOSED_COUNT" -gt 0 ]; then
      ADVERSARY="$(basename "$(dirname "$FILE_PATH")")"
      cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "✅ game-dev-team: ${ADVERSARY} review closed ${CLOSED_COUNT} pending queue entr$([ "$CLOSED_COUNT" -gt 1 ] && echo "ies" || echo "y") based on its based_on references."
  }
}
EOF
    fi
    exit 0
    ;;
esac

# ============================================================
# Path 2: Watched artifact written → append a pending queue entry.
# ============================================================
ADVERSARIES=""
SECTION=""

case "$FILE_PATH" in
  */docs/game/design/*)
    SECTION="design"
    ADVERSARIES="design-critic, accessibility-critic, fact-checker-conceptual"
    ;;
  */docs/game/spec/*)
    SECTION="spec"
    ADVERSARIES="constraints-critic, accessibility-critic, fact-checker-platform"
    ;;
  */docs/game/platform/*)
    SECTION="platform"
    ADVERSARIES="execution-realist, constraints-critic, fact-checker-platform"
    ;;
  */docs/game/perf/*)
    SECTION="perf"
    ADVERSARIES="execution-realist"
    ;;
  */docs/game/art/*)
    SECTION="art"
    ADVERSARIES="design-critic"
    ;;
  */docs/game/narrative/*)
    SECTION="narrative"
    ADVERSARIES="fact-checker-conceptual"
    ;;
  */docs/game/playtest/*)
    SECTION="playtest"
    ADVERSARIES="design-critic, fact-checker-conceptual"
    ;;
  *)
    # Inside docs/game/ but not in a watched subdirectory.
    exit 0
    ;;
esac

mkdir -p "$QUEUE_DIR"
REL_PATH="${FILE_PATH#*/docs/game/}"

printf '{"timestamp":"%s","tool":"%s","file":"docs/game/%s","section":"%s","suggested_adversaries":"%s","status":"pending"}\n' \
  "$TIMESTAMP" "$TOOL_NAME" "$REL_PATH" "$SECTION" "$ADVERSARIES" \
  >> "$QUEUE_FILE"

PENDING_COUNT="$(grep '"status":"pending"' "$QUEUE_FILE" 2>/dev/null | wc -l | tr -d ' ')"

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "📋 game-dev-team: queued review for docs/game/${REL_PATH} (section: ${SECTION}). Suggested adversaries: ${ADVERSARIES}. Review queue depth: ${PENDING_COUNT}. Run /game-dev-team:doctor to inspect, or invoke the suggested adversary directly."
  }
}
EOF

exit 0
