#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
url=$(echo "$input" | jq -r '.tool_input.url // empty')

if [[ "$url" == *"github.com"* ]]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "GitHub URLs don't work with WebFetch (JavaScript-rendered). Use mcp__github__* MCP tools or the gh CLI instead."
  }
}
EOF
  exit 0
fi

exit 0
