# beads-starter

*[English](README.md) · 한국어*

> [beads](https://github.com/steveyegge/beads) 워크플로우 규약을 프로젝트에
> 적용하는 두 가지 방식: 항시 발동 bash 설치형, 그리고 Claude Code · Codex
> CLI에서 쓰는 명시적 발동 skill 묶음.
>
> **Unofficial.** beads 공식 프로젝트와 관련 없습니다.

## 모드 선택

| | 항시 발동 모드 | 명시적 발동 모드 |
|---|---|---|
| 메커니즘 | bash 설치 스크립트가 대상 레포 파일에 콘텐츠 주입 | 세 개의 skill을 명시적으로 호출했을 때만 로드 |
| 워크플로우 적용 시점 | 매 세션 자동 | `bds-workflow` skill을 명시적으로 호출했을 때만 |
| 배포 채널 | `curl | bash` | Claude Code 플러그인 marketplace 또는 `curl | bash`(Codex) |
| 에이전트 호환성 | `AGENTS.md`를 읽는 모든 에이전트 (Claude Code, Cursor, Codex, …) | Claude Code, Codex CLI |
| 이런 사람에게 | 매번 의식하지 않아도 워크플로우가 적용되길 원하거나 여러 AI 에이전트 도구를 함께 씀 | 작업별로 명시적으로 켜고 싶음 |

두 모드는 상호 배타입니다 — 하나만 고르세요. 같은 레포에 둘 다 설치하면
워크플로우 규칙이 두 번 로드됩니다.

- **항시 발동 모드** — [`always-on/README.ko.md`](always-on/README.ko.md) 참조
- **명시적 발동 모드** — [`on-demand/README.ko.md`](on-demand/README.ko.md) 참조

## 동작 모드

두 모드 모두 beads를 **shared-server** 모드(로컬 전용, Dolt 원격 없음)로
구성합니다. git worktree 작업 흐름과 단일 머신 사용에 맞춘 설정입니다. 실제
실행할 `bd init` 명령은 항시 발동 모드의 경우 주입된
`docs/beads-starter/bd-setup.md`에, 명시적 발동 모드의 경우 `bds-setup`
skill에 그대로 들어갑니다.

## 라이센스

[MIT](LICENSE)
