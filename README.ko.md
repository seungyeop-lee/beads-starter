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

---

## 항시 발동 모드 (bash 설치형)

beads 워크플로우 규약을 대상 레포 파일(`.gitignore`, `AGENTS.md`,
`docs/beads-starter/*`)에 주입하는 원샷 bash 설치 스크립트입니다. 설치 후에는
`AGENTS.md`를 읽는 에이전트라면 매 세션 워크플로우가 적용됩니다.

### 무엇을 주입하는가

- `.gitignore` — beads 생성물(`.beads/`, `.dolt/`, `*.db`)을 소스 관리에서
  제외
- `AGENTS.md` 섹션 — beads 기반 에이전트 워크플로우(10단계 흐름, 이슈 작성
  규칙, 커밋 규약, 셸 안전성)
- `docs/beads-starter/bd-setup.md` — 최초 `bd init` 설정 가이드 (사용자가
  지정한 prefix로 템플릿됨)
- `docs/beads-starter/beads-commands.md` — 자주 쓰는 `bd` 명령어 예제

주입되는 모든 콘텐츠는 `beads-starter` 마커 주석으로 감싸져 있어, 재실행 시
내부만 갱신되고 언인스톨 시에도 마커 밖의 사용자 콘텐츠는 그대로 보존됩니다.

### 설치

대상 레포 루트에서 실행합니다.

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- install
```

대화식 모드에서 beads 이슈 prefix(기본값: 현재 디렉토리 이름)와 진행 여부를
확인한 뒤 파일을 씁니다.

#### 비대화식

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- install --yes
```

prefix를 현재 디렉토리 이름으로 고정하고 프롬프트 없이 즉시 실행합니다.

### 업데이트

starter의 payload가 갱신된 뒤 대상 레포를 최신으로 맞추려면:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- update
```

- 마커 구간 **내부만** 현재 `main`의 콘텐츠로 교체됩니다. 마커 밖의 사용자
  콘텐츠는 그대로 보존됩니다.
- prefix는 기존 `docs/beads-starter/bd-setup.md` 마커 구간에서 자동
  추출되므로, 기본값이 아닌 prefix로 설치했더라도 안전합니다. 비대화식입니다.
- 마커 구간이 없거나(= 미설치) prefix 추출에 실패하면 에러로 종료합니다.
- 새 주입 대상이 추가된 경우 해당 파일이 새로 생성됩니다.
- 주입 대상이 제거된 경우(드뭄) 기존 파일은 정리되지 않으므로 해당 경로를
  수동 삭제하거나 `uninstall` 후 `install`로 리셋하세요.

### 언인스톨

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- uninstall --yes
```

대상 레포의 모든 `beads-starter` 마커 구간을 제거합니다. 마커 구간만 들어
있던 파일은 빈 파일로 남으며, 삭제는 사용자가 수동으로 합니다.

`.beads/` 디렉토리, `bd` CLI 바이너리, `~/.beads/shared-server/` 등 bd가
설치·생성한 아티팩트는 건드리지 않습니다. 실행 후 이들 항목을 직접 정리할
수 있도록 경로 안내 메시지를 출력합니다.

### 커맨드

- `install [--yes|-y]` — 마커 구간을 주입하여 설치. `--yes`는 프롬프트
  생략.
- `update` — 기존 prefix를 유지하며 마커 구간 내부를 재주입. 플래그 없음,
  항상 비대화식.
- `uninstall [--yes|-y]` — 마커 구간 제거. `--yes`는 확인 프롬프트 생략.
- `-h`, `--help` — 사용법 출력. `<command> --help`로 서브커맨드별 상세 출력
  지원.

### 구버전 URL

레이아웃 변경 이전 URL(`…/main/beads-starter.sh`, `always-on/` 세그먼트
없음)은 새 위치로 redirect하는 thin shim으로 계속 동작하며 stderr로
deprecation 안내를 출력합니다. 고정 참조는 편한 시점에 갱신해 주세요.

---

## 명시적 발동 모드 (Claude Code 또는 Codex)

beads 워크플로우 규약을 세 개의 skill로 노출합니다. 사용자가 명시적으로
호출했을 때만 로드됩니다. 레포의 작업 파일은 수정하지 않으며, 모든 콘텐츠는
호스트 도구가 skill을 보관하는 위치에 존재합니다.

### Skills

- `bds-workflow` — 10단계 워크플로우 규칙(register → close)을 로드. 이슈
  작성 규칙, 셸 안전성, 커밋 규칙, 명령 예제는 필요 시점에 보조 파일을
  참조합니다.
- `bds-setup` — bd 미설치 시 설치 안내, 프로젝트 init 진행(`bd init` +
  config). 하이브리드 방식 — 각 명령을 출력하고 실행 여부 확인.
- `bds-status` — ready 이슈와 현재 in-progress 상태 요약.

세 skill 모두 명시적으로 호출했을 때만 동작하며, 세션 내용에 기반해 자동
발동되지 않습니다.

### Claude Code

이 레포를 Claude Code 플러그인 marketplace로 추가한 뒤, 그 marketplace에서
`beads-starter` 플러그인을 설치합니다. 정확한 marketplace add/install 절차는
사용 중인 Claude Code 버전 문서를 참고하세요.

슬래시 커맨드로 호출: `/bds-workflow`, `/bds-setup`, `/bds-status`.

### Codex CLI

세 skill을 Codex의 skill 디렉터리로 복사하는 bash 설치 스크립트입니다. 별도
Codex 플러그인 매니페스트는 필요 없습니다 — Codex가 skill 디렉터리의
`SKILL.md`를 자동 디스커버리합니다.

#### 설치

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- install
```

대화식 모드에서 스코프(`user` 또는 `project`)를 묻습니다.

- `user` — `~/.codex/skills/bds-*/` (머신 전체. `$CODEX_HOME`이 설정돼 있으면
  그 경로를 따름)
- `project` — `<cwd>/.agents/skills/bds-*/` (현재 레포 한정. 협업자와
  공유하려면 디렉터리를 버전 관리에 포함)

비대화식:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- install --scope=user --yes
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- install --scope=project --yes
```

Codex CLI가 실행 중이라면 새 skill을 인식하도록 재시작하세요. Codex 안에서
호출은 `/skills` UI 또는 `$bds-workflow` 멘션으로 합니다. 정확한 UI는
[Codex skills 문서](https://developers.openai.com/codex/skills)를 참고하세요.

#### 업데이트

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- update --scope=user --yes
```

세 skill 디렉터리를 최신 콘텐츠로 교체합니다. 선택한 스코프에 beads-starter
skill이 없으면 에러로 종료합니다.

#### 언인스톨

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- uninstall --scope=user --yes
```

선택한 스코프에서 `bds-workflow/`, `bds-setup/`, `bds-status/` 디렉터리만
제거합니다. 같은 부모 디렉터리의 다른 skill은 건드리지 않습니다.

### 레포 초기화

bd를 한 번도 쓰지 않은 레포에서 `bds-setup` skill을 호출:

- Claude Code: `/bds-setup`
- Codex CLI: `/skills`에서 `bds-setup` 선택, 또는 `$bds-setup` 멘션

bd 설치(없으면), prefix 선택, init/config 네 개 명령을 안내합니다.

### 워크플로우 사용

beads 관련 작업을 시작할 때 `bds-workflow` skill을 호출합니다. 10단계
워크플로우 규칙을 로드하고 세션이 끝날 때까지 컨텍스트에 남아 있습니다. 큐
상태는 `bds-status`로 언제든 확인하세요.

### 항시 발동 모드에서 전환하기

이미 항시 발동 모드가 설치된 레포(`AGENTS.md`와 `docs/beads-starter/*`에
마커 존재)에 명시적 발동 모드를 추가하려면, 워크플로우 규칙 중복 로드를
피하기 위해 먼저 항시 발동 모드를 언인스톨하세요:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- uninstall --yes
```

---

## 동작 모드

두 모드 모두 beads를 **shared-server** 모드(로컬 전용, Dolt 원격 없음)로
구성합니다. git worktree 작업 흐름과 단일 머신 사용에 맞춘 설정입니다. 실제
실행할 `bd init` 명령은 항시 발동 모드의 경우 주입된
`docs/beads-starter/bd-setup.md`에, 명시적 발동 모드의 경우 `bds-setup`
skill에 그대로 들어갑니다.

## 라이센스

[MIT](LICENSE)
