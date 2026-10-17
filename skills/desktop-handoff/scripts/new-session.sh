#!/bin/sh
# Opens a new Claude Code session in the Claude desktop app.
#
# Usage: new-session.sh <folder> <title> [model]
# Creates the session in <folder> with a one-word seed turn, opens it in the desktop app,
# and prints its app session id (local_<uuid>) on the last line. Send it work with
# SendMessage. Needs macOS, the Claude desktop app, and claude, jq and script on PATH.
set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "usage: new-session.sh <folder> <title> [model]" >&2
  exit 2
fi
for tool in claude jq script; do
  command -v "$tool" >/dev/null || {
    echo "desktop-handoff: $tool not found on PATH" >&2
    exit 1
  }
done
cd "$1"
title=$2
model=${3-}

# The new session starts from a clean environment so it does not inherit this session's
# identity (session id, messaging socket). Sign-in, proxy and config folder pass through.
set -- HOME="$HOME" PATH="$PATH" LANG="${LANG:-en_US.UTF-8}" \
  ${USER:+"USER=$USER"} ${LOGNAME:+"LOGNAME=$LOGNAME"} ${SHELL:+"SHELL=$SHELL"} \
  ${TMPDIR:+"TMPDIR=$TMPDIR"} ${CLAUDE_CONFIG_DIR:+"CLAUDE_CONFIG_DIR=$CLAUDE_CONFIG_DIR"} \
  ${ANTHROPIC_API_KEY:+"ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY"} \
  ${ANTHROPIC_AUTH_TOKEN:+"ANTHROPIC_AUTH_TOKEN=$ANTHROPIC_AUTH_TOKEN"} \
  ${ANTHROPIC_BASE_URL:+"ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"} \
  ${HTTPS_PROXY:+"HTTPS_PROXY=$HTTPS_PROXY"} ${NO_PROXY:+"NO_PROXY=$NO_PROXY"}

seed=$(env -i "$@" TERM=dumb claude -p ${model:+--model "$model"} --effort low \
  --system-prompt-snapshot off -n "$title" --output-format json \
  "This turn only opens the session for a handoff. Reply with the single word: ready. Do not use tools." \
  </dev/null) || {
  echo "desktop-handoff: claude -p failed: $seed" >&2
  exit 1
}
session_id=$(printf '%s' "$seed" | jq -er 'select(.is_error | not) | .session_id') || {
  echo "desktop-handoff: no session id from claude -p: $seed" >&2
  exit 1
}
# --desktop needs a terminal, so script(1) gives it one (macOS syntax).
env -i "$@" TERM=xterm-256color script -q /dev/null claude --desktop --resume "$session_id" </dev/null
echo "local_$session_id"
