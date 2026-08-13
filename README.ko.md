<h1 align="center">seudesign</h1>

<p align="center">
  <em>시스템 설계를 읽지 말고 실행하세요.</em><br>
  A system design skill for Claude Code — design docs, architecture reviews,
  mock interviews, capacity estimation.
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/SeuPut0705/seudesign?style=flat-square&color=111111&label=stars" alt="Stars">
  <img src="https://img.shields.io/badge/skill-Claude%20Code-111111?style=flat-square" alt="Claude Code skill">
  <img src="https://img.shields.io/badge/cases-5-111111?style=flat-square" alt="5 case studies">
  <img src="https://img.shields.io/badge/works%20with-Claude%20Code%20%C2%B7%20Codex%20%C2%B7%20Copilot%20%C2%B7%20AGENTS.md-111111?style=flat-square" alt="Multi-agent">
</p>

<p align="center">
  <sub><a href="README.md">English</a> &middot; 한국어 &middot; <a href="README.ja.md">日本語</a> &middot; <a href="README.zh.md">中文</a></sub>
</p>

---

레퍼런스 문서가 아니라 **작동하는 스킬**입니다. 4가지 모드로 Claude가
직접 설계하고, 진단하고, 면접을 봐줍니다. 참조는 한국어지만 결과물은
대화 언어를 따라갑니다 (works in any language).

## 모드

| 명령 | 하는 일 |
|---|---|
| `/sdp design 채팅 서비스` | 요구사항 인터뷰 → 추정 → 다이어그램 포함 설계 문서 생성 |
| `/sdp review` | 현재 코드베이스 아키텍처 진단 — 단일 장애점, 타임아웃 부재, 멱등성 구멍을 파일:줄로 |
| `/sdp interview` | 모의 시스템 설계 면접 — 3단계 힌트, 루브릭 채점 |
| `/sdp estimate 이미지 서비스` | 대화형 용량 추정 — RPS/저장량 + 설계 분기점 해석 |

## 설치

### Claude Code

```
/plugin marketplace add SeuPut0705/seudesign
```
```
/plugin install sdp@seudesign
```

(두 명령을 각각 보내야 합니다)

### Codex

```bash
codex plugin marketplace add SeuPut0705/seudesign
codex plugin add sdp@seudesign
```

### GitHub Copilot CLI

```bash
copilot plugin marketplace add SeuPut0705/seudesign
copilot plugin install sdp@seudesign
```

### OpenCode / Cursor / AGENTS.md 계열

저장소를 클론해 열면 [AGENTS.md](AGENTS.md)가 자동 로드됩니다.
전역 설치는 아래 스크립트로.

### 그 외 (범용)

```bash
curl -fsSL https://raw.githubusercontent.com/SeuPut0705/seudesign/main/install.sh | sh
```

스킬 디렉토리를 읽는 모든 에이전트용. `DEST=경로`로 대상 변경 가능.

## 담긴 내용

```
skills/sdp/
  SKILL.md                    # 4개 모드 워크플로 + 결정 프레임워크 + 철칙
  references/
    architecture.md           # LB, 프록시, CDN, 게이트웨이, 모놀리스 vs MSA
    data.md                   # DB 확장 사다리, 샤딩, consistent hashing, 캐시
    async.md                  # 큐, 전달 보장, 멱등성, 백프레셔, outbox
    reliability.md            # 가용성 산식, 서킷브레이커, 레이트리밋, 관측성
    patterns.md               # saga, 이벤트 소싱, CQRS, 분산 락, fan-out
    estimation.md             # 지연시간 어림값, 트래픽/저장량 추정 절차
    interview.md              # 면접 플레이북, 루브릭, 흔한 실수 6가지
    checklists.md             # 아키텍처 진단 + 프로덕션 준비 점검표
    cases/                    # 완성 설계 5종
      url-shortener.md        #   ID 생성, 캐시, 301 vs 302
      rate-limiter.md         #   token bucket, fail-open, Redis Lua
      chat-system.md          #   WebSocket 상태, 순서 보장, presence
      news-feed.md            #   fan-out 하이브리드, celebrity 문제
      file-storage.md         #   청크, 중복 제거, 델타 동기화, 충돌
```

## 설계 철학

- **조기 확장 금지** — 인프라 패턴은 병목이 증명된 뒤에.
- **모든 선택은 트레이드오프 한 쌍** — 무엇을 얻고 무엇을 포기하는가.
- **숫자 없이 설계 없다** — 추정치라도 깔고 시작.

## 예시

```
> /sdp review

아키텍처 진단 결과 (심각도순)

| 위치 | 심각도 | 증상 | 처방 |
|---|---|---|---|
| api/client.py:42 | 치명 | requests.get에 타임아웃 없음 | timeout=(3,10) + 재시도 예산 |
| worker/consume.py:18 | 높음 | 소비자 멱등성 없음 + at-least-once 큐 | 처리 ID 테이블 + unique 제약 |
...
```
