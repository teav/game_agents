#!/bin/bash
# log-invocation.sh
#
# SubagentStart hook for the game-dev-team plugin.
# Logs every subagent invocation to docs/game/logs/agent-invocations.jsonl so
# /game-dev-team:doctor can report on usage patterns across sessions.
#
# Non-blocking: always exits 0.

set -eu

INPUT="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

AGENT_TYPE="$(echo "$INPUT" | jq -r '.agent_type // empty')"

# Only log invocations of agents from this plugin. Plugin-scoped agents are namespaced
# (e.g., "game-dev-team:producer"), and bare names are local user agents we don't track.
case "$AGENT_TYPE" in
  game-dev-team:*) ;;
  producer|game-designer|systems-architect|art-director|narrative|design-critic|market-analyst|fact-checker-conceptual|platform-lead|implementation|performance|build-pipeline|execution-realist|constraints-critic|fact-checker-platform) ;;
  *) exit 0 ;;
esac

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

LOG_DIR="$PROJECT_DIR/docs/game/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/agent-invocations.jsonl"

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
SESSION_ID="$(echo "$INPUT" | jq -r '.session_id // "unknown"')"

printf '{"timestamp":"%s","agent":"%s","session_id":"%s"}\n' \
  "$TIMESTAMP" "$AGENT_TYPE" "$SESSION_ID" \
  >> "$LOG_FILE"

exit 0
