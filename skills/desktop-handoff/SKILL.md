---
name: desktop-handoff
description: Hands the current conversation, or one part of it, to a new Claude Code session that appears in the Claude desktop app's sidebar and starts working right away, with no click. Use when the user asks to hand off, continue in a new chat or session, or move a task into its own session ("hand this off", "continue in a new session", "인계해", "새 채팅으로 넘어가", "새 세션에서 해"), including when the app's own session-starting tool is missing or refuses to start one.
compatibility: macOS with the Claude desktop app (Code tab). Needs the claude CLI (signed in), jq and script on PATH. Run it from a session in the desktop app.
---

# desktop-handoff

Opens a new Claude Code session in the Claude desktop app and starts it on a handoff message. The new session is a normal sidebar session in the folder you choose, and its first turn starts as soon as the message arrives.

## Steps

1. **Write the handoff message** with the template below. Take it from the conversation's conclusions, not from tool output, and keep it under about 40 lines. When you split off one topic, include only that topic. Write "none" for an empty item.
2. **Create the session and open it in the app.** Run the script in this skill's base directory:
   ```bash
   sh "<this skill's base directory>/scripts/new-session.sh" "<folder>" "<short title>" "<your model id>"
   ```
   - `<folder>`: where the new session works. Use this session's folder unless the work belongs to another repository.
   - `<your model id>`: your own model, so the new session matches. Leave it out to use the CLI default.
   - The last line of the output is the new session's id, `local_<uuid>`. The app switches to the new session.
   - If the script fails, show its error to the user and stop.
3. **Send the handoff message** with `SendMessage`, `to` set to that `local_<uuid>`. `delivered` means the new session's turn has started. If you have no `SendMessage` tool, use the desktop app's `send_message` tool with that session id.
4. **Tell the user** the new session's title and what stays in this session.

## Handoff message template

Leave out the last sentence of the first paragraph when you hand off the whole conversation and this session has nothing more to do.

```
This is a handoff from another session. Start on the latest request and the next steps right away and carry them through. Leave the user's open decisions to the user and list them in your report. When you finish, send a short report of what you did and what is left with SendMessage to the session in this message's `from`.

Goal:
Latest request (the user's words, verbatim):
Constraints (the user's instructions and prohibitions):
Done so far:
Decisions and reasons:
Open decisions (for the user):
Next steps:
Key facts (numbers, conclusions):
Relevant files:
```
