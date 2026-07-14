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
    "permissionDecisionReason": "GitHub URLs don't work with WebFetch (JavaScript-rendered). Use the gh CLI instead (gh api, gh pr view, gh issue view)."
  }
}
EOF
  exit 0
fi

exit 0
