# 항시 발동 모드 (bash 설치형)

*[English](README.md) · 한국어*

beads 워크플로우 규약을 대상 레포 파일(`.gitignore`, `AGENTS.md`,
`docs/beads-starter/*`)에 주입하는 원샷 bash 설치 스크립트입니다. 설치 후에는
`AGENTS.md`를 읽는 에이전트라면 매 세션 워크플로우가 적용됩니다.

## 무엇을 주입하는가

- `.gitignore` — beads 생성물(`.beads/`, `.dolt/`, `*.db`)을 소스 관리에서
  제외
- `AGENTS.md` 섹션 — beads 기반 에이전트 워크플로우(10단계 흐름, 이슈 작성
  규칙, 커밋 규약, 셸 안전성)
- `docs/beads-starter/bd-setup.md` — 최초 `bd init` 설정 가이드 (사용자가
  지정한 prefix로 템플릿됨)
- `docs/beads-starter/beads-commands.md` — 자주 쓰는 `bd` 명령어 예제

주입되는 모든 콘텐츠는 `beads-starter` 마커 주석으로 감싸져 있어, 재실행 시
내부만 갱신되고 언인스톨 시에도 마커 밖의 사용자 콘텐츠는 그대로 보존됩니다.

## 설치

대상 레포 루트에서 실행합니다.

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- install
```

대화식 모드에서 beads 이슈 prefix(기본값: 현재 디렉토리 이름)와 진행 여부를
확인한 뒤 파일을 씁니다.

### 비대화식

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- install --yes
```

prefix를 현재 디렉토리 이름으로 고정하고 프롬프트 없이 즉시 실행합니다.

## 업데이트

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

## 언인스톨

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/always-on/beads-starter.sh | bash -s -- uninstall --yes
```

대상 레포의 모든 `beads-starter` 마커 구간을 제거합니다. 마커 구간만 들어
있던 파일은 빈 파일로 남으며, 삭제는 사용자가 수동으로 합니다.

`.beads/` 디렉토리, `bd` CLI 바이너리, `~/.beads/shared-server/` 등 bd가
설치·생성한 아티팩트는 건드리지 않습니다. 실행 후 이들 항목을 직접 정리할
수 있도록 경로 안내 메시지를 출력합니다.

## 커맨드

- `install [--yes|-y]` — 마커 구간을 주입하여 설치. `--yes`는 프롬프트
  생략.
- `update` — 기존 prefix를 유지하며 마커 구간 내부를 재주입. 플래그 없음,
  항상 비대화식.
- `uninstall [--yes|-y]` — 마커 구간 제거. `--yes`는 확인 프롬프트 생략.
- `-h`, `--help` — 사용법 출력. `<command> --help`로 서브커맨드별 상세 출력
  지원.

## 구버전 URL

레이아웃 변경 이전 URL(`…/main/beads-starter.sh`, `always-on/` 세그먼트
없음)은 새 위치로 redirect하는 thin shim으로 계속 동작하며 stderr로
deprecation 안내를 출력합니다. 고정 참조는 편한 시점에 갱신해 주세요.
