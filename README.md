# beads-starter

> 기존 프로젝트 레포에 [beads](https://github.com/steveyegge/beads) 워크플로우
> 프리셋을 주입하는 원샷 설치 스크립트.
>
> **Unofficial.** beads 공식 프로젝트와 관련 없습니다.

## 무엇을 하는가

대상 레포에서 실행하면 아래 네 가지를 마커 구간 형태로 주입합니다.

- `.gitignore` — beads 생성물(`.beads/`, `.dolt/`, `*.db`)을 소스 관리에서
  제외
- `AGENTS.md` 섹션 — beads 기반 에이전트 워크플로우(등록부터 종료까지
  10단계 흐름, 이슈 작성 규칙, 커밋 규약, 셸 안전성)
- `docs/bd-setup.md` — 최초 `bd init` 설정 가이드 (사용자가 지정한 prefix로
  템플릿됨)
- `docs/beads-commands.md` — 자주 쓰는 `bd` 명령어 예제

주입되는 모든 콘텐츠는 `beads-starter` 마커 주석으로 감싸져 있어, 재실행 시
내부만 갱신되고 언인스톨 시에도 마커 밖의 사용자 콘텐츠는 그대로 보존됩니다.

## 설치

대상 레포 루트에서 실행합니다.

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/install.sh | bash
```

대화식 모드에서 beads 이슈 prefix(기본값: 현재 디렉토리 이름)와 진행 여부를
확인한 뒤 파일을 씁니다.

### 비대화식

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/install.sh | bash -s -- --yes
```

prefix를 현재 디렉토리 이름으로 고정하고 프롬프트 없이 즉시 실행합니다.

### 언인스톨

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/install.sh | bash -s -- --uninstall
```

대상 레포의 모든 `beads-starter` 마커 구간을 제거합니다. 마커 구간만 들어
있던 파일은 빈 파일로 남으며, 삭제는 사용자가 수동으로 합니다.

`.beads/` 디렉토리, `bd` CLI 바이너리, `~/.beads/shared-server/` 등 bd가
설치·생성한 아티팩트는 건드리지 않습니다. 실행 후 이들 항목을 직접 정리할
수 있도록 경로 안내 메시지를 출력합니다.

## 옵션

- `--yes`, `-y` — 대화식 프롬프트 건너뛰고 디폴트 사용
- `--uninstall` — 마커 구간 제거
- `-h`, `--help` — 사용법 출력

## 동작 모드

프리셋은 beads를 **shared-server** 모드(로컬 전용, Dolt 원격 없음)로
구성합니다. git worktree 작업 흐름과 단일 머신 사용에 맞춘 설정입니다.
주입된 `docs/bd-setup.md`에 실제 실행할 `bd init` 명령이 그대로 들어갑니다.

## 설치 이후

1. `bd` CLI 설치 (`docs/bd-setup.md` 참조)
2. `docs/bd-setup.md`의 `bd init` 명령 실행
3. `AGENTS.md`의 워크플로우에 따라 작업
