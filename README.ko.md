<div align="center">

[English](README.md) · **한국어**

# desktop-handoff

**Claude 데스크톱 앱(Code 탭)의 Claude Code 세션에서, 지금 대화(또는 그중 한 주제)를 새 세션에 넘기는 스킬.**

새 세션은 앱 사이드바의 일반 세션으로 뜨고, 누르지 않아도 바로 일을 시작하며, 끝나면 넘긴 세션에 짧게 보고한다.

[![test](https://github.com/moneycode11101-svg/claude-code-desktop-handoff/actions/workflows/test.yml/badge.svg)](https://github.com/moneycode11101-svg/claude-code-desktop-handoff/actions/workflows/test.yml) [![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![Claude Code 2.1.302](https://img.shields.io/badge/Claude%20Code-2.1.302-d97757.svg)](#지원-범위)

<img src="docs/demo-ko.gif" width="880" alt="시연: Claude 데스크톱 앱 세션이 인계 메시지를 작성해 사이드바에 새 세션을 열고, 메시지를 보내 새 세션이 바로 일을 시작한 뒤, 끝나면 넘긴 세션으로 보고를 돌려보내는 모습">

<sub>이 페이지용으로 다시 꾸민 예시 세션이다. 실제 프로젝트 화면이 아니다.</sub>

[설치](#설치) · [쓰는 법](#쓰는-법) · [지원 범위](#지원-범위) · [동작](#동작)

</div>

## 왜

앱이 Claude에게 새 세션을 직접 열게 해 주는 도구는 일부 판에만 있고, 사용자가 앱에서 직접 친 턴에서만 된다. 그 밖(다른 판, 알림이나 다른 세션이 깨운 턴, 폰 리모트 컨트롤 턴)에는 누를 카드를 남기거나, 앱에 안 보이는 곳에서 일을 돌리는 수밖에 없다.

`desktop-handoff`는 어떤 턴에서든 데스크톱 앱 사이드바에 일반 세션을 열고, 누르지 않아도 첫 턴이 바로 시작되게 한다.

## 설치

2026-10-17 `skills` CLI 1.7.2로 확인:

```bash
npx skills add moneycode11101-svg/claude-code-desktop-handoff -g -a claude-code
```

`~/.claude/skills/desktop-handoff`에 깔린다.

`git`으로 깔려면:

```bash
git clone https://github.com/moneycode11101-svg/claude-code-desktop-handoff.git
cp -R claude-code-desktop-handoff/skills/desktop-handoff ~/.claude/skills/
```

깐 뒤 데스크톱 앱에서 새 세션을 연다.

## 쓰는 법

Claude 데스크톱 앱(Code 탭) 세션에서 `"이건 새 세션으로 넘겨"`, `"새 채팅으로 넘어가"`, `"hand this off to a new session"`처럼 말하거나 `/desktop-handoff`를 실행한다.

그러면 Claude가:

1. **인계 메시지를 쓴다** (도구 출력이 아니라 대화의 결론에서 뽑아 약 40줄 안쪽으로 작성):
   - 목표 (Goal)
   - 최신 요청 원문 (Latest request, verbatim)
   - 제약 — 사용자의 지시와 금지 사항 (Constraints)
   - 한 것 (Done so far)
   - 결정과 이유 (Decisions and reasons)
   - 사용자 몫 결정 (Open decisions)
   - 다음 단계 (Next steps)
   - 핵심 사실 — 숫자·결론 (Key facts)
   - 관련 파일 (Relevant files)
2. **`scripts/new-session.sh`로 그 폴더에 세션을 만들어 앱에 연다** (폴더, 짧은 제목, 지금 세션의 모델 ID를 넘긴다).
3. **`SendMessage`로 메시지를 보낸다** (`to`를 `local_<uuid>`로 지정. `SendMessage` 도구가 없으면 데스크톱 앱의 `send_message` 도구를 쓴다).

새 세션의 첫 턴이 바로 시작되고, 끝나면 한 일과 남은 일(사용자 몫 결정 포함)을 보낸 세션에 `SendMessage`로 짧게 보고한다.

## 지원 범위

| | 상태 |
|---|---|
| macOS 26 (Apple silicon) + Claude 데스크톱 앱 2.31226.1 + Claude Code CLI 2.1.302 | 확인함 (2026-10-17) |
| 더 새 데스크톱 앱 판 | 아직 안 해 봄 |
| Intel 맥, 더 옛 macOS | 아직 안 해 봄 |
| Windows, Linux | 지원 안 함 (macOS `script` 문법을 쓴다) |
| 데스크톱 앱 없이 터미널만 | 지원 안 함 |

`PATH`에 필요한 것:

- **`claude`**: Claude Code CLI, 로그인한 상태 ([설치 안내](https://code.claude.com/docs/en/setup))
- **`jq`**: 요즘 macOS는 `/usr/bin/jq`, 없으면 `brew install jq`
- **`script`**: macOS 기본

## 동작

1. `claude -p -n "<제목>" --output-format json`이 그 폴더에서 한 단어짜리 시드 턴(`ready`, `--effort low --system-prompt-snapshot off`, 도구 미사용)을 돌려 세션을 만들고 id를 받는다.
2. `claude --desktop --resume <id>`가 그 세션을 앱 사이드바 일반 세션으로 연다(폴더·제목·모델 그대로, 터미널이 있어야 해서 `script -q /dev/null`로 감싼다).
3. `SendMessage`(`to`는 `local_<id>`)가 메시지를 넣으면 앱이 그 턴을 바로 시작한다.

스크립트는 깨끗한 환경(`env -i`)에서 `claude`를 띄워 지금 세션의 id·메시지 소켓은 넘기지 않고, 로그인·프록시·설정 폴더 변수(`HOME`, `PATH`, `LANG`, `USER`, `LOGNAME`, `SHELL`, `TMPDIR`, `CLAUDE_CONFIG_DIR`, `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL`, `HTTPS_PROXY`, `NO_PROXY`)는 넘긴다.

실측(2026-10-17): 시드 턴에 약 3초(2.6초)가 걸리고 짧은 모델 호출 한 번이 더 든다. 앱 안 세션이 이 스킬을 써서 같은 폴더에 새 세션을 만들고, 새 세션이 일을 하고 보고를 돌려보내는 데까지 확인했다.

## 업데이트·제거

```bash
npx skills update desktop-handoff -g
```

```bash
npx skills remove desktop-handoff -g
```

`git`으로 깔았으면 다시 받아 덮어쓰거나 아래 명령으로 지운다:

```bash
rm -rf ~/.claude/skills/desktop-handoff
```

## 개발

```bash
git clone https://github.com/moneycode11101-svg/claude-code-desktop-handoff.git
cd claude-code-desktop-handoff
```

```bash
sh tests/new-session.test.sh
```

```bash
shellcheck skills/desktop-handoff/scripts/*.sh tests/*.sh
```

```bash
shfmt -d skills tests
```

`tests/new-session.test.sh`는 가짜 `claude`로 17개 항목을 확인한다.

## 한 식구

같은 사람이 낸 [claude-code-live-viewer](https://github.com/moneycode11101-svg/claude-code-live-viewer)와 한 식구다.

## 라이선스

[MIT](LICENSE)
