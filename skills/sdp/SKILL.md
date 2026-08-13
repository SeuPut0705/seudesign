---
name: sdp
description: >-
  시스템 설계 실전 스킬. 설계 문서 생성(design), 현재 코드베이스 아키텍처
  진단(review), 모의 면접(interview), 용량 추정(estimate) 모드 제공.
  아키텍처 설계, 구조 개선, 확장성 검토, 기술 선택 트레이드오프(CAP, 캐시,
  큐, DB 샤딩, 로드밸런서, 마이크로서비스), 신뢰성 패턴(서킷브레이커,
  멱등성, 레이트리밋), 시스템 설계 면접 준비 시 사용.
---

# sdp — 시스템 설계 스킬

레퍼런스이자 실행 도구다. 사용자가 모드를 지정하면 해당 워크플로를
그대로 수행하고, 지정 없이 설계 주제가 나오면 참조만 활용한다.
참조 문서는 한국어지만 결과물은 항상 **사용자의 대화 언어**로 작성한다.

## 모드

### `design <시스템 설명>` — 설계 문서 생성

1. 요구사항을 인터뷰한다: 기능 3~5개로 압축, 비기능(DAU, 읽기/쓰기 비율,
   지연 목표, 일관성 요구)을 질문. 사용자가 모르면 합리적 가정을 제시하고
   확인받는다.
2. [estimation.md](references/estimation.md) 절차로 RPS/저장량을 계산해
   보여준다.
3. 고수준 설계: 컴포넌트 다이어그램(mermaid), 데이터 흐름, API 초안,
   데이터 모델.
4. 핵심 컴포넌트 1~2개 상세화 + 병목 지목 + 확장안.
5. 각 선택마다 대안과 버린 이유를 표로. 결과물은 하나의 마크다운 설계
   문서로 저장한다 (경로는 사용자에게 확인).
   유사 사례가 [cases/](references/cases/)에 있으면 골격으로 활용한다.

### `review [경로]` — 아키텍처 진단

현재 코드베이스를 읽고 [checklists.md](references/checklists.md)의 진단
항목으로 점검한다. 결과는 심각도순 표 (파일:줄 + 증상 + 처방):

1. 구조 파악: 진입점, 컴포넌트 경계, 외부 의존(DB/캐시/큐/외부 API).
2. 점검: 단일 장애점, 타임아웃 없는 외부 호출, 무한 재시도, 멱등성 없는
   소비자, 캐시 무효화 전략 부재, 상태 있는 서버, N+1, 인덱스 부재,
   무한 큐, 관측성 공백.
3. 처방은 [빠른 결정 프레임워크](#빠른-결정-프레임워크)와 참조 문서
   기준으로, 현재 규모에 맞는 최소 조치를 우선한다 (조기 확장 금지).

### `interview [문제]` — 모의 면접

[interview.md](references/interview.md)의 진행 규칙을 따른다. 요약:
면접관 역할로 문제 제시 → 단계마다 사용자가 먼저 답하게 하고 →
힌트는 3단계(방향→개념→예시)로만 → 종료 시 루브릭 채점표 + 개선점.
사용자가 문제를 안 정하면 난이도를 물어 cases/에서 고른다.

### `estimate <대상>` — 용량 추정

[estimation.md](references/estimation.md) 절차로 대화형 추정. 가정을
표로 명시하고, 자릿수 암산 과정을 보여주고, 결과가 의미하는 설계
분기점(단일 서버로 되는가, 캐시가 필요한가, 샤딩 시점인가)까지 해석한다.

## 철칙 (모든 모드 공통)

- **조기 확장 금지.** 인프라 패턴은 병목이 증명된 뒤에. 기본값은 모듈형
  모놀리스 + PostgreSQL + 필요할 때 캐시.
- **모든 선택은 트레이드오프 한 쌍으로** — "무엇을 얻고 무엇을 포기하는가".
- **상태를 줄여라.** 무상태 컴포넌트는 공짜로 확장된다.
- **숫자 없이 설계 없다.** 추정치라도 반드시 숫자를 깔고 시작한다.

## 빠른 결정 프레임워크

| 증상 | 1차 처방 | 그다음 |
|---|---|---|
| 읽기 느림 | 인덱스, 쿼리 튜닝 | 캐시 → 읽기 복제본 |
| 쓰기 느림 | 배치/비동기화 | 파티셔닝 → 샤딩 |
| 요청 폭주 | 레이트리밋, 큐잉 | 수평 확장 + LB |
| 느린 외부 호출 | 타임아웃 + 재시도 | 서킷브레이커, 비동기화 |
| 단일 장애점 | 복제본 + 헬스체크 | 자동 failover |
| 중복 처리 사고 | 멱등 키 | outbox + 멱등 소비자 |

## 참조

- [architecture.md](references/architecture.md) — LB, 프록시, CDN, API
  게이트웨이, 모놀리스 vs 마이크로서비스
- [data.md](references/data.md) — DB 확장 사다리, 복제, 샤딩, consistent
  hashing, SQL/NoSQL 선택, 캐시 전략
- [async.md](references/async.md) — 큐, 전달 보장, 멱등성, 백프레셔, outbox
- [reliability.md](references/reliability.md) — 가용성 산식, CAP, 서킷
  브레이커, 레이트리밋, failover, 관측성
- [networking.md](references/networking.md) — DNS, TCP/UDP, RPC vs REST,
  폴링/WebSocket/SSE 선택
- [patterns.md](references/patterns.md) — saga, 이벤트 소싱, CQRS, 분산 락,
  리더 선출, fan-out
- [estimation.md](references/estimation.md) — 추정 수치와 절차
- [interview.md](references/interview.md) — 면접 플레이북, 루브릭, 흔한 실수
- [checklists.md](references/checklists.md) — 설계 리뷰·프로덕션 준비 점검표
- [cases/](references/cases/) — 완성 설계: url-shortener, rate-limiter,
  chat-system, news-feed, file-storage, web-crawler, search-autocomplete
