# system-design-skill

[system-design-primer](https://github.com/donnemartin/system-design-primer)의
핵심을 증류한 Claude Code 스킬 (`sdp`).

A Claude Code skill distilling the system-design-primer into a compact,
agent-loadable reference.

## 담긴 내용

- **설계 4단계 방법론** — 유스케이스 정리 → 고수준 설계 → 핵심 컴포넌트 → 확장
- **개념 참조** — CAP, 일관성/가용성 패턴, CDN·로드밸런서, DB 복제·샤딩,
  캐시 전략, 비동기 큐, 통신 프로토콜
- **용량 추정** — 2의 거듭제곱 표, latency numbers, 가용성 수치

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
  SKILL.md                  # 진입점: 방법론 + 라우팅
  references/
    concepts.md             # 주제별 핵심 개념
    estimation.md           # back-of-the-envelope 수치
```

## 출처

모든 내용은 [donnemartin/system-design-primer](https://github.com/donnemartin/system-design-primer)
(CC BY 4.0)를 요약·번역한 것이다.
