<div align="center">

**English** · [한국어](README.ko.md)

# desktop-handoff

**Hand off your Claude Code conversation to a fresh session in the Claude desktop app—with zero clicks.**

Opens right in the sidebar, starts working immediately, and sends a report back when finished.

[![test](https://github.com/moneycode11101-svg/claude-code-desktop-handoff/actions/workflows/test.yml/badge.svg)](https://github.com/moneycode11101-svg/claude-code-desktop-handoff/actions/workflows/test.yml) [![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![Claude Code 2.1.302](https://img.shields.io/badge/Claude%20Code-2.1.302-d97757.svg)](#requirements)

<img src="docs/demo.gif" width="880" alt="Demo: A session in the Claude desktop app writes a handoff message, opens a new session in the sidebar, sends the message so the new session starts working right away, and receives a short report when it finishes">

<sub>A sample session recreated for this page. Nothing in it comes from a real project.</sub>

[Install](#install) · [Usage](#usage) · [Requirements](#requirements) · [How it works](#how-it-works)

</div>

## What it does

When a conversation gets too long or you want to branch off a subtask, `desktop-handoff` opens a real session in your desktop app's sidebar. Unlike default handoffs, it doesn't wait for you to click a button—it starts working right away and reports the results back to your original session.

## Install

```bash
npx skills add moneycode11101-svg/claude-code-desktop-handoff -g -a claude-code
```

Or install with `git`:

```bash
git clone https://github.com/moneycode11101-svg/claude-code-desktop-handoff.git
cp -R claude-code-desktop-handoff/skills/desktop-handoff ~/.claude/skills/
```

After installing, open a new session in the Claude desktop app.

## Usage

In any Claude Code session (Code tab), say it naturally or use the command:

* `"hand this off to a new session"`
* `"continue in a new session"`
* `/desktop-handoff`

**What happens automatically:**

1. Claude summarizes the goal, progress, decisions, and files.
2. A new session opens in the desktop app sidebar for that folder.
3. The new session starts immediately and sends a brief summary back when done.

## Requirements

|  | Status |
| --- | --- |
| macOS 26 (Apple silicon), Claude desktop app 2.31226.1, Claude Code CLI 2.1.302 | Tested (2026-10-17) |
| Newer Claude desktop app builds | Not tested yet |
| Intel Mac, older macOS versions | Not tested yet |
| Windows, Linux | Not supported (uses macOS `script` syntax) |
| Terminal only (without the Claude desktop app) | Not supported |

Needed on `PATH`:

* **`claude`**: Claude Code CLI, signed in ([setup guide](https://code.claude.com/docs/en/setup))
* **`jq`**: `/usr/bin/jq` on recent macOS; otherwise `brew install jq`
* **`script`**: included with macOS

## How it works

1. Runs a quick seed turn (`claude -p`) to create the session ID (~3s).
2. Opens that session in the sidebar via `claude --desktop --resume <id>` wrapped in `script`.
3. Sends the context via `SendMessage` so the new session starts working immediately in a clean environment.

## Manage & Development

**Update / Remove:**

```bash
npx skills update desktop-handoff -g
npx skills remove desktop-handoff -g
```

*(If installed with `git`: `rm -rf ~/.claude/skills/desktop-handoff`)*

**Tests:**

```bash
git clone https://github.com/moneycode11101-svg/claude-code-desktop-handoff.git
cd claude-code-desktop-handoff
sh tests/new-session.test.sh
shellcheck skills/desktop-handoff/scripts/*.sh tests/*.sh
shfmt -d skills tests
```

## Related & License

* **Sister project:** [claude-code-live-viewer](https://github.com/moneycode11101-svg/claude-code-live-viewer)
* **License:** [MIT](LICENSE)
