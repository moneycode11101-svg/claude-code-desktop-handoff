#!/bin/sh
# Tests skills/desktop-handoff/scripts/new-session.sh against a fake claude on PATH.
# Run: sh tests/new-session.test.sh
set -u

root=$(cd "$(dirname "$0")/.." && pwd)
under_test="$root/skills/desktop-handoff/scripts/new-session.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin" "$work/folder"
folder_real=$(cd "$work/folder" && pwd -P)
test_path="$work/bin:$(dirname "$(command -v jq)"):$(dirname "$(command -v script)"):/usr/bin:/bin"
session=11111111-2222-3333-4444-555555555555

# The fake logs its arguments, environment and folder, and answers as the mode file says.
cat >"$work/bin/claude" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"$work/calls"
env >>"$work/env"
pwd -P >>"$work/pwd"
case "\$1" in
-p)
  case "\$(cat "$work/mode")" in
  ok) echo '{"type":"result","is_error":false,"session_id":"$session","result":"ready"}' ;;
  error) echo '{"type":"result","is_error":true,"session_id":"$session","result":"Not logged in"}' ;;
  crash) echo boom; exit 1 ;;
  esac ;;
--desktop) echo "Opening session \$3 in Claude Desktop" ;;
esac
EOF
chmod +x "$work/bin/claude"

failures=0
check() {
  name=$1
  shift
  if "$@"; then
    echo "ok - $name"
  else
    echo "not ok - $name"
    failures=$((failures + 1))
  fi
}
# run <fake mode> <script arguments...>: keeps stdout, stderr and the exit status.
run() {
  echo "$1" >"$work/mode"
  shift
  rm -f "$work/calls" "$work/env" "$work/pwd"
  env -i HOME="$work" PATH="$test_path" CLAUDECODE=1 CLAUDE_CODE_SESSION_ID=parent \
    CLAUDE_CONFIG_DIR="$work/config" sh "$under_test" "$@" >"$work/out" 2>"$work/err"
  status=$?
}

run ok "$work/folder" "My title" claude-opus-5-5
check "exits 0" [ "$status" -eq 0 ]
check "prints the app session id last" [ "$(tail -n 1 "$work/out")" = "local_$session" ]
check "runs claude in the folder" [ "$(head -n 1 "$work/pwd")" = "$folder_real" ]
check "seed gets model, title and json output" grep -q -- \
  "^-p --model claude-opus-5-5 --effort low --system-prompt-snapshot off -n My title --output-format json " \
  "$work/calls"
check "opens the session in the desktop app" grep -qx -- "--desktop --resume $session" "$work/calls"
check "drops this session's identity" sh -c "! grep -q -e '^CLAUDECODE=' -e '^CLAUDE_CODE_SESSION_ID=' '$work/env'"
check "keeps the config folder" grep -qx "CLAUDE_CONFIG_DIR=$work/config" "$work/env"

run ok "$work/folder" "No model"
check "passes no --model without a model" sh -c "! grep -q -- --model '$work/calls'"

run error "$work/folder" "Title"
check "fails when claude reports an error" [ "$status" -eq 1 ]
check "says there is no session id" grep -q "no session id" "$work/err"
check "does not open the app after an error" sh -c "! grep -q -- --desktop '$work/calls'"

run crash "$work/folder" "Title"
check "fails when claude -p fails" [ "$status" -eq 1 ]
check "shows claude's output" grep -q "claude -p failed: boom" "$work/err"

run ok "$work/folder"
check "needs a title" [ "$status" -eq 2 ]
check "prints usage" grep -q "^usage:" "$work/err"

mv "$work/bin/claude" "$work/claude.off"
run ok "$work/folder" "Title"
check "fails without claude on PATH" [ "$status" -eq 1 ]
check "names the missing tool" grep -q "claude not found" "$work/err"

[ "$failures" -eq 0 ]
