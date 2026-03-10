#!/usr/bin/env bash
# Symphony launcher - run with: symphony [agent] [project_slug]
# Agents: codex (default), claude, gemini
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CALL_DIR="$(pwd)"

# 1. Load symphony's own config (API keys etc.)
for envfile in "$SCRIPT_DIR/.env" "$SCRIPT_DIR/.env.local"; do
  if [ -f "$envfile" ]; then
    set -a; source "$envfile"; set +a
  fi
done

# 2. Load calling project's .env.local (project slug etc.) — overrides symphony's values
if [ -f "$CALL_DIR/.env.local" ] && [ "$CALL_DIR" != "$SCRIPT_DIR" ]; then
  set -a; source "$CALL_DIR/.env.local"; set +a
fi

AGENT="${1:-codex}"
PROJECT_SLUG="${2:-$LINEAR_PROJECT_SLUG}"

if [ -z "$LINEAR_API_KEY" ]; then
  echo "Error: LINEAR_API_KEY is not set. Copy .env.example to .env and fill it in."
  exit 1
fi

WORKFLOW="$SCRIPT_DIR/workflows/WORKFLOW-${AGENT}.md"

if [ ! -f "$WORKFLOW" ]; then
  echo "Error: Unknown agent '${AGENT}'. Available: codex, claude, gemini"
  exit 1
fi

# Patch project_slug if provided
if [ -n "$PROJECT_SLUG" ]; then
  TMP=$(mktemp)
  sed "s/YOUR_PROJECT_SLUG/$PROJECT_SLUG/" "$WORKFLOW" > "$TMP"
  WORKFLOW="$TMP"
fi

echo "Starting Symphony with agent: $AGENT"
if [ -n "$PROJECT_SLUG" ]; then
  echo "Project:  $PROJECT_SLUG"
fi
echo ""

"$SCRIPT_DIR/elixir/bin/symphony" \
  --i-understand-that-this-will-be-running-without-the-usual-guardrails \
  "$WORKFLOW"
