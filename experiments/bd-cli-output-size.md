# bd CLI 출력 크기 측정

**일시**: 2026-04-23
**bd 버전**: 1.0.2 (Homebrew)
**배경**: beads-starter 워크플로우를 따라 작업할 때 각 `bd` 명령의 출력이
LLM 컨텍스트에서 얼마나 토큰을 잡아먹는지 실측하여, "실행 중 누적 비용"이
큰 지점을 식별하기 위함.

## 측정 환경

- 스크래치 디렉토리 `/tmp/bdtestskIDaZ` (측정 후 삭제)
- 이 starter 기본 프리셋으로 init:
  - `bd init --shared-server --prefix bdtestskIDaZ --skip-agents --skip-hooks`
  - `bd config set no-git-ops true`
  - `bd config set export.git-add false`
  - `bd config unset sync.remote`
- 측정법: `printf '%s' "$out" | wc -c` (trailing newline 제외 실바이트)

## 샘플 이슈 description

이 starter 규약(WHAT / METHOD / Out of Scope / Verification)에 맞춘
현실적 길이 — 약 360 바이트.

```
## WHAT
Fix the login retry timeout bug on the auth page.

## METHOD
Increase the retry timeout to 30s and add exponential backoff with jitter.

### Out of Scope
Password reset flow is not in scope.

## Verification
- Timeout constant updated in auth/login.ts
- Exponential backoff applied
- Unit tests pass for 3 retry scenarios
```

## 결과 — 읽기 계열

| 명령 | 바이트 | 비고 |
|---|---:|---|
| `bd show <id>` (0 comments) | 485 | description 전체 포함 |
| `bd show <id>` (2 comments + notes) | 726 | |
| `bd show <id>` (7 comments + notes) | 1346 | comment당 약 +120B 선형 누적 |
| `bd show <id> --short` | 57 | 제목 1줄. 기본 대비 88~96% 감소 |
| `bd show <id> --long` | 485 | 이 이슈엔 추가 필드 없어 기본과 동일 |
| `bd show <id> --json` | 649 | **기본보다 큼**. 키 반복 오버헤드 |
| `bd ready` (4 issues) | 397 | 1줄/이슈 + legend/요약 |
| `bd ready --plain` | 284 | legend 제거, 28% 감소 |
| `bd ready --json` | 2889 | description 전체 dump, **7배 증가** |
| `bd comments <id>` (2 comments) | 178 | show보다 훨씬 가벼움 |
| `bd comments <id> --json` | 436 | 2.4배 |

## 결과 — 쓰기 계열

| 명령 | 기본 | `-q` | 차이 |
|---|---:|---:|---|
| `bd create ...` | 204 | — | "💡 Tip: Install the beads plugin..." 광고 3줄 포함 |
| `bd create ... --silent` | 16 | — | ID만. 92% 감소 |
| `bd update <id> --status=in_progress` | 63 | 56 | 7B (무의미) |
| `bd update <id> --claim` | 64 | — | assignee + status=in_progress 원자화 |
| `bd comment <id> "..."` | 65 | 65 | 0 |
| `bd close <id> --reason=...` | 65 | 61 | 4B (무의미) |

## 결론

1. **`--json`은 토큰 절감 도구가 아니다.** `bd ready --json`은 기본 대비
   7배, `bd show --json`은 1.3배. 사용 배제.
2. **`-q`는 쓰기 계열에서 사실상 효과 없음.** 이미 한 줄 ~60B라 ± 몇
   바이트 수준. 가이드에 반영할 가치 없음.
3. **가장 큰 누적 절감 여지 = `bd show`의 comment 누적 비용.** comment
   개수에 선형 비례(+120B/comment). Step 8에서 커밋 메시지 전문을 comment에
   저장하는 현재 관행이 장기 이슈에서 가장 큰 비용원. "해시 + 짧은 subject"
   로 제약하면 최대 효과.
4. **가장 큰 고정 절감 = `bd create --silent`.** 호출당 약 188B 절감.
   Register / mid-execution discovery에서 매번 발생.
5. **`bd show --short`는 "훑기 전용".** Step 2(스펙 확인), Step 5
   (Verification 실행) 같은 풀 확인에는 못 씀. 다른 이슈 빠른 조회 용도에만
   유용.
6. **`bd update --claim`**: Step 3의 `--status=in_progress`를 대체 가능.
   출력 바이트는 동일하지만 "assignee까지 원자 처리"라는 의미가 추가.
7. **`bd comments <id>` 단독 조회(178B)가 `bd show`(726B+)보다 3~7배 가벼움.**
   "최근 comment 확인" 용도엔 `bd comments`가 적합.

## 재현 절차

```bash
TDIR=$(mktemp -d /tmp/bdtestXXXXXX)
PFX=$(basename "$TDIR")
cd "$TDIR"
git init -q
git config user.email "test@local" && git config user.name "tester"
PAYLOAD_BASE="file://<this-repo>/payload" \
  bash <this-repo>/beads-starter.sh install --yes
bd init --shared-server --prefix "$PFX" --skip-agents --skip-hooks
bd config set no-git-ops true
bd config set export.git-add false
bd config unset sync.remote
# 이후 bd create / show / update / comment / close 실행 후
# printf '%s' "$out" | wc -c 로 측정
# cleanup:
rm -rf "$TDIR" ~/.beads/shared-server/dolt/"$PFX"/
```
