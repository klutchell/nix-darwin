#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
url=$(echo "$input" | jq -r '.tool_input.url // empty')

if [[ "$url" == *"github.com"* ]]; then
  echo "Use mcp__github__* MCP tools for GitHub URLs, not WebFetch." >&2
  exit 2
fi

exit 0
