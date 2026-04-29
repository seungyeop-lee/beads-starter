# Agents

## 프로젝트 개요

`beads-starter`는 [beads](https://github.com/steveyegge/beads) 워크플로우
규약을 프로젝트에 적용하는 두 가지 모드를 제공합니다:

- **항시 발동 모드**(bash 설치형) — 대상 레포의 `AGENTS.md` 등에 콘텐츠를
  주입해 매 세션 자동 적용. 진입점은 `always-on/beads-starter.sh`이며 루트
  `beads-starter.sh`는 URL 안정성을 위한 thin shim입니다.
- **명시적 발동 모드**(Claude Code 플러그인) — `on-demand/` 하위 플러그인을
  사용자가 슬래시 커맨드(`/bds-workflow`, `/bds-setup`, `/bds-status`)로
  명시적으로 호출했을 때만 발동.

이 레포 자체는 beads 워크플로우를 사용하지 않습니다. `.beads/` 초기화,
beads 이슈 등록, `bd` 상태 전환은 적용 대상 레포에 들어가는 운영 규칙이지
이 starter 프로젝트의 작업 절차가 아닙니다.

## 구조

```
beads-starter/
├── beads-starter.sh                         # 루트 shim — URL 안정성용 thin wrapper
├── always-on/                               # 항시 발동 모드
│   ├── beads-starter.sh                     # 정본 bash 진입점
│   └── payload/                             # 대상 레포에 주입되는 콘텐츠
│       ├── gitignore.part
│       ├── AGENTS.md.part
│       └── docs/beads-starter/
│           ├── bd-setup.md.part
│           └── beads-commands.md.part
├── on-demand/                               # 명시적 발동 모드
│   ├── .claude-plugin/plugin.json
│   └── skills/
│       ├── bds-workflow/                    # 10단계 워크플로우 + 보조 파일
│       │   ├── SKILL.md
│       │   ├── issue-content.md
│       │   ├── shell-safety.md
│       │   ├── commit-rules.md
│       │   └── commands.md
│       ├── bds-setup/SKILL.md
│       └── bds-status/SKILL.md
└── .claude-plugin/marketplace.json          # self-marketplace 진입점
```

각 `always-on/payload/*.part` 파일은 **마커 구간 안에 들어갈 콘텐츠**이지
완성된 파일이 아닙니다. `always-on/beads-starter.sh`는 실행 시점에 이
파일들을 HTTPS로 가져와(이 레포 `main` 브랜치 GitHub raw) 대상 파일에
주입합니다.

이 네 파일 외에 `always-on/beads-starter.sh`는 대상 레포의 `CLAUDE.md`에
`@AGENTS.md` 임포트 한 줄을 추가합니다. 마커 기반이 아니라 "같은 줄이 없을
때만 추가" 방식이며(`ensure_line`), 한 줄이 범용적이고 안정적이라 언인스톨
시에는 `CLAUDE.md`를 건드리지 않습니다.

## 모드 분리 원칙

- **상호 배타** — 두 모드는 동시에 사용하지 않습니다. 강제하지 않고 README와
  skill 안내 수준에서만 가이드합니다(같은 레포에 둘 다 적용되면 워크플로우
  콘텐츠가 두 번 로드됨).
- **콘텐츠 동기화 의무 없음** — 워크플로우 콘텐츠는 두 모드에 의도적으로
  중복 보관되며, 자동 동기화하지 않습니다. 두 모드는 독립적으로 진화할 수
  있습니다(공통 콘텐츠 유지보수 권고는 아래 별도 섹션 참조).
- **모드 명칭 고정** — `항시 발동 모드`(영문 *always-on mode*)와 `명시적 발동
  모드`(영문 *on-demand mode*)는 README/skill description에서 동일하게
  사용합니다. 변경 시 모든 노출 지점을 한 커밋에서 갱신합니다.

## 불변조건

아래 다섯 가지는 어떤 변경에서도 유지되어야 합니다.

1. **멱등성** — `always-on/beads-starter.sh install`(또는 `update`)을 두 번
   실행했을 때의 대상 레포 상태는 한 번 실행했을 때와 같아야 합니다. 마커
   구간 내부만 교체하고, 마커 밖 콘텐츠는 절대 건드리지 않는 방식으로
   보장합니다.
2. **마커 문자열은 계약** — open/close 마커 문자열은 starter가 관리하는
   구간을 식별하는 안정적 키입니다. 바꾸면 기존 설치본의 멱등성이
   깨집니다(다음 실행이 기존 구간을 찾지 못해 새 구간을 덧붙여 중복
   생성됨). 부득이하게 변경해야 한다면 마이그레이션 경로를 함께
   설계하십시오.
3. **`curl | bash` 경로가 동작해야 함** — 스크립트는 stdin으로 파이프되어
   실행됩니다. 디스크상의 스크립트 파일 경로에 의존하는 로직(`$0` 상대
   경로 등)을 추가하지 마십시오.
4. **`bash` + `curl` + POSIX 유틸리티 외 의존성 금지** — 대상 머신에는 bash
   (macOS, Linux)는 있지만 Node·Python 등은 없을 수 있습니다.
5. **URL 안정성** — 루트 `beads-starter.sh`(shim)는 호환용으로 유지됩니다.
   레이아웃 변경 이전에 사용자에게 공유된 `…/main/beads-starter.sh` URL이
   계속 동작해야 하므로, shim을 제거하거나 hardcoded redirect 위치를 변경할
   때는 deprecation 기간을 충분히 둡니다. shim 자체에 로직을 추가하지
   마십시오 — `curl … always-on/beads-starter.sh | bash -s -- "$@"` 패턴만
   유지합니다.

## `always-on/` 편집

### `always-on/payload/*.part`

- `{{PREFIX}}`가 **유일한** 템플릿 변수입니다. `always-on/beads-starter.sh`가
  `sed "s/{{PREFIX}}/${PREFIX}/g"`로 치환합니다. 템플릿 변수를 더 추가하려면
  `always-on/beads-starter.sh`도 함께 수정해야 합니다.
- `AGENTS.md.part`는 `## Beads Workflow`(H2)로 시작합니다. 대상 `AGENTS.md`는
  공유 파일이라 사용자의 H1이 이미 있을 수 있으므로, 주입 콘텐츠는 서브섹션
  레벨에 둡니다.
- `docs/*.md.part`는 각각 H1으로 시작합니다. starter가 새로 만드는 파일이기
  때문입니다.
- `docs/beads-starter/bd-setup.md.part`의 `## Expected warnings` 섹션은 현재
  프리셋 플래그 (`--shared-server`, `--skip-hooks` 등) 하에서 정상인 경고만
  나열합니다. 플래그나 운영 모드를 바꾸는 커밋에서는 이 섹션도 함께
  갱신하십시오.

### `always-on/beads-starter.sh`

이미 처리한 플랫폼 이슈들입니다. 리그레션에 주의하십시오.

- **BSD `awk` 예약어** — macOS는 BSD awk를 기본으로 제공하며, `close`가 내장
  함수명이라 `-v` 변수명으로 사용할 수 없습니다. 코드에서는 `mopen` /
  `mclose`로 우회했습니다.
- **`curl | bash`에서 stdin 사용 불가** — 스크립트 자체가 stdin이라 일반
  `read`는 동작하지 않습니다. 모든 대화식 입출력은 `/dev/tty`로 명시적으로
  리디렉션해야 합니다.
- **`sed` 치환 안전성** — prefix에 `/`, `&`, `\`가 섞이면 치환이 깨집니다.
  스크립트는 PREFIX를 `^[a-zA-Z0-9_-]+$`로 검증합니다.

### 루트 `beads-starter.sh` (shim)

URL 안정성용 thin wrapper입니다.

- 로직을 추가하지 마십시오 — `curl … always-on/beads-starter.sh | bash -s --
  "$@"` 패턴만 유지합니다.
- deprecation 안내는 stderr로 출력하고, stdout은 정본 스크립트의 출력만
  통과해야 합니다.
- shim URL과 정본 URL을 동시에 옮기지 마십시오 — 호환이 깨집니다.

## `on-demand/` 편집

### Skill 분류 원칙

- `bds-workflow`는 항시 필요한 규칙(10-step + concurrency + init check + setup
  exceptions)만 SKILL.md 본문에 두고, 발동 시점이 한정적인 콘텐츠(이슈 작성
  규칙, 셸 안전성, 커밋 규칙, bd 명령 레퍼런스)는 보조 파일로 분리해 SKILL.md
  에서 링크 참조합니다.
- `bds-setup`, `bds-status`는 단일 SKILL.md만 둡니다 — 분리할 만큼 분량이
  많지 않습니다.

### Description 형식

각 SKILL.md frontmatter `description`은 다음 형식을 지킵니다:

```
description: <간단한 영문 설명>. Runs only on explicit invocation.
```

이 suffix는 자동 발동을 억제하는 유일한 메커니즘이므로 누락하지
마십시오.

### 콘텐츠 언어

SKILL.md 본문, 보조 파일, description, skill이 사용자에게 출력하는 메시지
모두 **영문**입니다. `always-on/payload/`와 의도적으로 일치시킵니다.

### 슬래시 커맨드와 skill 이름

`/<skill-name>` 형태로 1:1 매칭됩니다. skill 이름을 변경하면 슬래시 커맨드도
같이 변경되며, README와 다른 skill에서의 cross-reference(예: `bds-setup`
SKILL.md가 `/bds-workflow` 안내)도 동시에 갱신해야 합니다.

### 플러그인 등록

루트 `.claude-plugin/marketplace.json`에서 `on-demand/`를 source로
가리킵니다. 플러그인 메타데이터는 `on-demand/.claude-plugin/plugin.json`에
별도로 존재하며, 두 파일의 `name`/`description`은 일치시키는 것이 좋습니다.

## 모드 간 공통 콘텐츠 유지보수

워크플로우 콘텐츠(10-step, WHAT/METHOD, shell safety 등)는 두 모드에
**의도적으로 중복 보관**됩니다. 자동 동기화는 강제하지 않되, 변경 시 양쪽을
검토하기를 권고합니다:

- **버그 수정·오타** — 양쪽 모두 반영을 기본으로 하되 강제하지 않습니다.
- **새 규칙 추가** — 어느 모드에 적용할지 의식적으로 결정합니다.
- **의도적 분기** — 두 파일 모두에 분기를 인지할 수 있는 메모를 남깁니다.
  분기가 누적되면 "동기화 가정"이 위험해지므로 PR 시점에 한 번 짚어볼 것.

명칭(모드 명, 슬래시 커맨드, skill 이름)은 변경 시 **모든 노출 지점 동시
업데이트** — README(영/한 2종), AGENTS.md, skill description, 페이로드 내
참조.

## README 관리

`README.md`(영어, 기본)와 `README.ko.md`(한국어) 두 언어 버전이 존재합니다.
둘은 **같은 커밋 안에서 항상 내용이 일치**해야 합니다.

- 한쪽의 섹션을 추가·삭제·수정하면 다른 쪽도 **같은 커밋에서** 동일하게
  반영합니다. 번역 지연을 이유로 한쪽만 선행 머지하지 마십시오 — 다른
  언어 사용자가 잘못된 정보를 보게 됩니다.
- 각 파일 상단의 언어 스위처 줄(`*English · [한국어](README.ko.md)*` /
  `*[English](README.md) · 한국어*`)은 상대 파일 경로의 유일한 연결
  지점입니다. 제거하거나 경로를 바꾸면 상호 이동이 깨집니다.
- 파일명(`README.md`, `README.ko.md`)은 GitHub가 `README.md`를
  자동 렌더링한다는 사실에 의존한 계약입니다. 영어가 기본이어야 합니다.
- 새 언어를 추가한다면 `README.<lang>.md` 규약을 따르고, 기존 두 파일의
  스위처 줄에 새 링크를 **모두** 추가하십시오.

## 로컬 테스트

### 항시 발동 모드

레포 루트를 변수에 담고 스크래치 디렉토리에서 실행하는 패턴이 안정적입니다:

```
REPO_ROOT="<absolute path to this repo>"
mkdir -p /tmp/beads-starter-test/myproj
cd /tmp/beads-starter-test/myproj

PAYLOAD_BASE="file://${REPO_ROOT}/always-on/payload" bash "${REPO_ROOT}/always-on/beads-starter.sh" install --yes
PAYLOAD_BASE="file://${REPO_ROOT}/always-on/payload" bash "${REPO_ROOT}/always-on/beads-starter.sh" update
PAYLOAD_BASE="file://${REPO_ROOT}/always-on/payload" bash "${REPO_ROOT}/always-on/beads-starter.sh" uninstall --yes
```

스크래치 dirname에 점(`.`)이 들어가면 PREFIX 검증(`^[a-zA-Z0-9_-]+$`)에서
거부되므로 `mktemp` 기본값 대신 `myproj` 같은 깨끗한 이름을 사용하십시오.

`always-on/beads-starter.sh` 변경 시 반드시 커버해야 할 시나리오:

1. 최초 `install` (빈 디렉토리) — 4개 대상 파일이 마커 구간과 함께 생성.
2. `install` 재실행(마커 밖에 사용자 콘텐츠를 추가해 둔 상태) — starter
   구간만 교체, 사용자 콘텐츠 보존.
3. `update` — 미설치 상태에서는 에러, 설치 상태에서는 기존 prefix를
   `docs/beads-starter/bd-setup.md`의 `bd init --prefix X` 라인에서 역추출해
   멱등 재주입.
4. `uninstall` — 마커 구간 제거, 구간 밖 콘텐츠 보존.
5. 마커 불일치(open만 있거나 close만 있는 경우) — 파일을 수정하지 않고
   에러로 종료.
6. 서브커맨드 누락 / 알 수 없는 서브커맨드 — usage를 출력하고 비영(非零)
   종료코드로 실패.

루트 shim의 end-to-end 동작(원격 fetch)은 `main`에 push된 후에만 검증
가능합니다. 구문/구조는 다음으로 확인:

```
bash -n beads-starter.sh
bash -n always-on/beads-starter.sh
```

### 명시적 발동 모드

플러그인을 marketplace에 정식 설치하기 전이라도 로컬에서 검증 가능:

- JSON 유효성:

  ```
  python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))"
  python3 -c "import json; json.load(open('on-demand/.claude-plugin/plugin.json'))"
  ```

- Skill frontmatter 형식: 각 `SKILL.md` 첫 블록이 `---`로 감싼 YAML이며
  `name`과 `description`을 포함하는지 확인.
- 보조 파일 참조: SKILL.md가 링크하는 보조 파일 경로(`issue-content.md` 등)가
  실제로 존재하는지 확인.

설치 후 동작은 Claude Code에서 marketplace를 추가하고 플러그인을 설치한 뒤
`/bds-workflow`, `/bds-setup`, `/bds-status` 호출로 검증합니다.

## 릴리스 플로우

배포 = `main`에 push. 별도의 릴리스 단계는 없습니다. `main`에 올라가는 모든
커밋은 두 모드(`always-on/`, `on-demand/`)와 루트 shim·marketplace 메타데이터
모두 일관된 상태여야 합니다.

### 항시 발동 모드 URL

- **정본**: `https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh`
  — README가 안내하는 URL.
- **호환 shim**: `https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/beads-starter.sh`
  — 레이아웃 변경 이전에 공유된 URL을 위한 호환용. 정본으로 redirect 후
  실행하며 deprecation 안내를 stderr로 출력.

`always-on/beads-starter.sh`가 페이로드를 같은 `main` 기준으로 가져오기
때문에, `main`에 올라가는 모든 커밋은 스크립트와 `always-on/payload/`가
일관된 상태여야 합니다.

### 명시적 발동 모드

루트 `.claude-plugin/marketplace.json`이 self-marketplace 진입점입니다.
사용자는 이 레포를 Claude Code 플러그인 marketplace로 추가하고 그 안의
`beads-starter` 플러그인을 설치합니다. 명시적 릴리스 시
`on-demand/.claude-plugin/plugin.json`의 `version` 필드를 갱신하십시오.
