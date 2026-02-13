#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

if [[ -z "$transcript" || ! -f "$transcript" ]]; then
  exit 0
fi

# Throttle: skip if checked less than 30s ago (keyed by session transcript)
throttle_file="/tmp/claude-context-monitor-$(echo "$transcript" | md5 -q 2>/dev/null || md5sum <<<"$transcript" | cut -d' ' -f1)"

if [[ -f "$throttle_file" ]]; then
  last_check=$(stat -f %m "$throttle_file" 2>/dev/null || stat -c %Y "$throttle_file" 2>/dev/null || echo 0)
  now=$(date +%s)
  if (( now - last_check < 30 )); then
    exit 0
  fi
fi
touch "$throttle_file"

# Get transcript size in KB
size_kb=$(( $(stat -f %z "$transcript" 2>/dev/null || stat -c %s "$transcript" 2>/dev/null || echo 0) / 1024 ))

if (( size_kb >= 760 )); then
  echo "CONTEXT CRITICAL (~95%) — Stop current work and start a new session. Save any important context to memory first." >&2
  exit 2
elif (( size_kb >= 680 )); then
  echo "Context usage HIGH (~85%) — Wrap up current task and consider starting a new session soon." >&2
  exit 2
elif (( size_kb >= 560 )); then
  echo "Context getting full (~70%) — Finish your current task, avoid starting new complex work." >&2
  exit 2
fi

exit 0
