---
name: sdp
description: >-
  system-design-primer(donnemartin) 핵심을 증류한 시스템 설계 참조.
  시스템/아키텍처 설계, 구조 개선, 확장성(scalability) 검토, 기술 선택
  트레이드오프(CAP, 캐시, 큐, DB 샤딩, 로드밸런서), 용량 추정
  (back-of-the-envelope), 시스템 설계 면접 준비 시 사용.
---

# sdp — System Design Primer 요약 스킬

출처: https://github.com/donnemartin/system-design-primer

## 설계 진행 4단계 (항상 이 순서)

1. **유스케이스·제약·가정 정리** — 누가 쓰나, 요청 수, 데이터량, 읽기/쓰기 비율.
2. **고수준 설계** — 주요 컴포넌트와 연결을 스케치.
3. **핵심 컴포넌트 상세화** — API, 데이터 모델, 병목 후보.
4. **확장** — 병목을 찾아 로드밸런서, 캐시, 샤딩, 큐 등을 필요한 곳에만 추가.

원칙: 처음부터 확장 설계하지 말 것. 벤치마크/프로파일로 병목을 증명한 뒤 확장.
모든 선택은 트레이드오프 — 정답이 아니라 제약에 맞는 균형을 고른다.

## 상세 참조

- [references/concepts.md](references/concepts.md) — 주제별 핵심: 성능 vs 확장성,
  CAP, 일관성/가용성 패턴, DNS/CDN/로드밸런서/리버스 프록시, 마이크로서비스,
  DB(복제·샤딩·NoSQL), 캐시 전략, 비동기 큐, 통신 프로토콜, 보안 기초.
- [references/estimation.md](references/estimation.md) — 용량 추정: 2의 거듭제곱 표,
  지연시간 비교 수치(latency numbers), 가용성 수치(99.9% 등), 추정 요령.

## 적용 요령

- 소규모 프로젝트에 적용할 때는 원칙만 가져온다: 관심사 분리, 느슨한 결합,
  단일 진입점, 단계별 합성. 로드밸런서·샤딩 같은 인프라 패턴은 규모가
  증명되기 전에 도입하지 않는다.
- 면접 답변 구조: 요구사항 → 고수준 → 상세 → 확장 순서로 말하고, 각 선택마다
  트레이드오프를 명시한다.
