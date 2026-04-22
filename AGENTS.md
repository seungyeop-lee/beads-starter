# Agents

## 프로젝트 개요

`beads-starter`는 [beads](https://github.com/steveyegge/beads) 워크플로우
규약을 기존 프로젝트 레포에 주입하는 원샷 설치 스크립트입니다. 주된 산출물은
**`install.sh`**이며, `payload/` 하위 파일들은 그 스크립트가 배포하는
페이로드입니다.

## 구조

```
install.sh           # bash 진입점, `curl | bash`로 실행
payload/             # 대상 레포에 주입되는 콘텐츠
├── gitignore.part          # → 대상 `.gitignore` 마커 구간
├── AGENTS.md.part          # → 대상 `AGENTS.md` 마커 구간
└── docs/
    ├── bd-setup.md.part       # → 대상 `docs/bd-setup.md` 마커 구간
    └── beads-commands.md.part # → 대상 `docs/beads-commands.md` 마커 구간
```

각 `.part` 파일은 **마커 구간 안에 들어갈 콘텐츠**이지 완성된 파일이 아닙니다.
`install.sh`는 실행 시점에 이 파일들을 HTTPS로 가져와(이 레포 `main` 브랜치
GitHub raw) 대상 파일에 주입합니다.

## 불변조건

아래 네 가지는 어떤 변경에서도 유지되어야 합니다.

1. **멱등성** — `install.sh`를 두 번 실행했을 때의 대상 레포 상태는 한 번
   실행했을 때와 같아야 합니다. 마커 구간 내부만 교체하고, 마커 밖 콘텐츠는
   절대 건드리지 않는 방식으로 보장합니다.
2. **마커 문자열은 계약** — open/close 마커 문자열은 starter가 관리하는 구간을
   식별하는 안정적 키입니다. 바꾸면 기존 설치본의 멱등성이 깨집니다(다음
   실행이 기존 구간을 찾지 못해 새 구간을 덧붙여 중복 생성됨). 부득이하게
   변경해야 한다면 마이그레이션 경로를 함께 설계하십시오.
3. **`curl | bash` 경로가 동작해야 함** — 스크립트는 stdin으로 파이프되어
   실행됩니다. 디스크상의 스크립트 파일 경로에 의존하는 로직(`$0` 상대
   경로 등)을 추가하지 마십시오.
4. **`bash` + `curl` + POSIX 유틸리티 외 의존성 금지** — 대상 머신에는 bash
   (macOS, Linux)는 있지만 Node·Python 등은 없을 수 있습니다.

## `payload/*.part` 편집

- `{{PREFIX}}`가 **유일한** 템플릿 변수입니다. `install.sh`가
  `sed "s/{{PREFIX}}/${PREFIX}/g"`로 치환합니다. 템플릿 변수를 더 추가하려면
  `install.sh`도 함께 수정해야 합니다.
- `AGENTS.md.part`는 `## Beads Workflow`(H2)로 시작합니다. 대상 `AGENTS.md`는
  공유 파일이라 사용자의 H1이 이미 있을 수 있으므로, 주입 콘텐츠는 서브섹션
  레벨에 둡니다.
- `docs/*.md.part`는 각각 H1으로 시작합니다. starter가 새로 만드는 파일이기
  때문입니다.

## `install.sh` 편집

이미 처리한 플랫폼 이슈들입니다. 리그레션에 주의하십시오.

- **BSD `awk` 예약어** — macOS는 BSD awk를 기본으로 제공하며, `close`가 내장
  함수명이라 `-v` 변수명으로 사용할 수 없습니다. 코드에서는 `mopen` /
  `mclose`로 우회했습니다.
- **`curl | bash`에서 stdin 사용 불가** — 스크립트 자체가 stdin이라 일반
  `read`는 동작하지 않습니다. 모든 대화식 입출력은 `/dev/tty`로 명시적으로
  리디렉션해야 합니다.
- **`sed` 치환 안전성** — prefix에 `/`, `&`, `\`가 섞이면 치환이 깨집니다.
  스크립트는 PREFIX를 `^[a-zA-Z0-9_-]+$`로 검증합니다.

## 로컬 테스트

페이로드 출처를 현재 작업 트리로 돌려 실행할 수 있습니다.

```
PAYLOAD_BASE="file://$(pwd)/payload" bash install.sh --yes
```

스크래치 디렉토리(예: `/tmp/beads-starter-test`)에서 실행하고 결과 파일을
검사하십시오.

`install.sh` 변경 시 반드시 커버해야 할 시나리오:

1. 최초 설치(빈 디렉토리) — 4개 대상 파일이 마커 구간과 함께 생성.
2. 재실행(마커 밖에 사용자 콘텐츠를 추가해 둔 상태) — starter 구간만 교체,
   사용자 콘텐츠 보존.
3. `--uninstall` — 마커 구간 제거, 구간 밖 콘텐츠 보존.
4. 마커 불일치(open만 있거나 close만 있는 경우) — 파일을 수정하지 않고
   에러로 종료.

커밋 전:

```
bash -n install.sh          # 구문 검사
```

## 릴리스 플로우

프로덕션 설치 URL은 `main` 브랜치에 하드코딩되어 있습니다.

```
https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/install.sh
```

배포 = `main`에 push. 별도의 릴리스 단계는 없습니다. `install.sh`가 페이로드를
같은 `main` 기준으로 가져오기 때문에, `main`에 올라가는 모든 커밋은
`install.sh`와 `payload/`가 일관된 상태여야 합니다.
