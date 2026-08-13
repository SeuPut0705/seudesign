# system-design-skill

시스템 설계 실전 레퍼런스를 담은 Claude Code 스킬 (`sdp`).

A Claude Code skill packing a practical, opinionated system design reference —
in Korean.

## 담긴 내용

- **설계 4단계 방법론** — 요구사항 고정 → 고수준 설계 → 핵심 상세화 → 병목 확인 후 확장
- **빠른 결정 프레임워크** — 증상별 1차 처방 표 (읽기 느림, 쓰기 느림, 요청 폭주…)
- **architecture** — 로드밸런서, 리버스 프록시, CDN, API 게이트웨이, 모놀리스 vs 마이크로서비스
- **data** — DB 확장 사다리, 복제, 샤딩, consistent hashing, SQL/NoSQL 선택표, 캐시 전략·스탬피드
- **async** — 큐, 전달 보장, 멱등성, 백프레셔, outbox 패턴, DLQ
- **reliability** — 가용성 산식, CAP, 타임아웃/재시도/서킷브레이커, 레이트리밋, failover, 관측성
- **estimation** — 단위 감각, 지연시간 어림값, 트래픽/저장량 추정 절차

## 설치

```bash
git clone https://github.com/SeuPut0705/system-design-skill.git
cp -R system-design-skill/sdp ~/.claude/skills/sdp
```

Claude Code에서 `/sdp`로 호출하거나, 시스템 설계·구조 개선·확장성 관련
대화에서 자동으로 참조된다.

## 구조

```
sdp/
  SKILL.md                  # 진입점: 방법론 + 결정 프레임워크 + 라우팅
  references/
    architecture.md
    data.md
    async.md
    reliability.md
    estimation.md
```

## 설계 철학

- 조기 확장 금지 — 인프라 패턴은 규모가 증명된 뒤에.
- 모든 선택은 트레이드오프 한 쌍으로.
- 상태를 줄이고, 남은 상태는 한곳에.
