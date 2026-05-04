# 명시적 발동 모드 (Claude Code 또는 Codex)

*[English](README.md) · 한국어*

beads 워크플로우 규약을 세 개의 skill로 노출합니다. 사용자가 명시적으로
호출했을 때만 로드됩니다. 레포의 작업 파일은 수정하지 않으며, 모든 콘텐츠는
호스트 도구가 플러그인 skill을 보관하는 위치에 존재합니다.

## Skills

- `bds-workflow` — 10단계 워크플로우 규칙(register → close)을 로드. 이슈
  작성 규칙, 셸 안전성, 커밋 규칙, 명령 예제는 필요 시점에 보조 파일을
  참조합니다.
- `bds-setup` — bd 미설치 시 설치 안내, 프로젝트 init 진행(`bd init` +
  config). 하이브리드 방식 — 각 명령을 출력하고 실행 여부 확인.
- `bds-status` — ready 이슈와 현재 in-progress 상태 요약.

세 skill 모두 명시적으로 호출했을 때만 동작하며, 세션 내용에 기반해 자동
발동되지 않습니다.

## Claude Code

이 레포를 Claude Code 플러그인 marketplace로 추가한 뒤, 그 marketplace에서
`beads-starter` 플러그인을 설치합니다.

```
/plugin marketplace add seungyeop-lee/beads-starter
/plugin install beads-starter@beads-starter
```

설치 후 `/reload-plugins`로 Claude Code 재시작 없이 플러그인을 활성화합니다.
설치 명령은 스코프(User, Project, Local)를 대화식으로 묻습니다.

슬래시 커맨드로 호출: `/bds-workflow`, `/bds-setup`, `/bds-status`.

## Codex

이 레포를 Codex 플러그인 marketplace로 추가한 뒤, Codex 플러그인 디렉터리에서
`beads-starter` 플러그인을 설치합니다.

### 설치

```bash
codex plugin marketplace add seungyeop-lee/beads-starter
```

marketplace 추가 후 Codex에서 `/plugins`를 실행합니다. `beads-starter`
marketplace를 선택하고, `beads-starter` 플러그인을 열어 설치합니다.

Codex 안에서 호출은 `/skills` UI 또는 `$bds-workflow` 멘션으로 합니다.
정확한 UI는 [Codex 플러그인 문서](https://developers.openai.com/codex/plugins)와
[Codex skills 문서](https://developers.openai.com/codex/skills)를 참고하세요.

### 업데이트

```bash
codex plugin marketplace upgrade beads-starter
```

이후 `/plugins`를 열고 Codex가 새 버전을 표시하면 업데이트하거나 다시
설치합니다.

### 언인스톨

Codex에서 `/plugins`를 사용해 `beads-starter` 플러그인을 언인스톨합니다.

### Legacy direct-skill cleanup

이 프로젝트의 예전 버전은 bash installer로 `bds-workflow/`, `bds-setup/`,
`bds-status/`를 Codex skill 디렉터리에 직접 복사했습니다. 새 설치는 위의
플러그인 경로를 사용하세요. 아래 cleanup 스크립트는 예전 direct-skill
복사본을 제거할 때만 사용합니다:

```bash
curl -sSL https://raw.githubusercontent.com/seungyeop-lee/beads-starter/main/on-demand/codex-installer.sh | bash -s -- uninstall --scope=user --yes
```

스코프:

- `user` — `~/.codex/skills/bds-*/` (머신 전체. `$CODEX_HOME`이 설정돼 있으면
  그 경로를 따름)
- `project` — `<cwd>/.agents/skills/bds-*/` (현재 레포 한정)

cleanup 스크립트는 선택한 스코프에서 `bds-workflow/`, `bds-setup/`,
`bds-status/` 디렉터리만 제거합니다. 같은 부모 디렉터리의 다른 skill은
건드리지 않습니다. 예전 `install`과 `update` 명령은 이제 Codex 플러그인
설치 안내를 출력하고 종료합니다.

## 레포 초기화

bd를 한 번도 쓰지 않은 레포에서 `bds-setup` skill을 호출:

- Claude Code: `/bds-setup`
- Codex: `/skills`에서 `bds-setup` 선택, 또는 `$bds-setup` 멘션

bd 설치(없으면), prefix 선택, init/config 네 개 명령을 안내합니다.

## 워크플로우 사용

beads 관련 작업을 시작할 때 `bds-workflow` skill을 호출합니다. 10단계
워크플로우 규칙을 로드하고 세션이 끝날 때까지 컨텍스트에 남아 있습니다. 큐
상태는 `bds-status`로 언제든 확인하세요.
