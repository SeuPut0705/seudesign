# Changelog

## 2.3.0 — 2026-08-13

- All skill content rewritten in English (lower token cost, better
  instruction-following; responses still follow the conversation language)
- Bundled `sdp-reviewer` agent — read-only architecture audit subagent
- `templates/design-doc.md` — fixed output skeleton for design mode
- `gemini-extension.json` — Gemini CLI support
- Manifests and install.sh messages in English

## 2.2.0 — 2026-08-13

- system-design-primer 대비 격차 해소: networking.md 추가 (DNS, TCP/UDP,
  RPC vs REST, 폴링/WebSocket/SSE)
- 케이스 스터디 7종으로 확대: web-crawler, search-autocomplete 추가

## 2.1.0 — 2026-08-13

- MIT 라이선스 추가
- GitHub Actions CI: 플러그인 구조 검증 + install.sh 문법 검사
- `examples/`: design / review 모드 실제 출력 샘플
- `evals/`: `claude plugin eval`용 평가 케이스 (스킬 품질 회귀 테스트)
- README 다국어 (en 기본, ko/ja/zh)

## 2.0.0 — 2026-08-13

- 실행형 스킬 전환: design / review / interview / estimate 4개 모드
- 케이스 스터디 5종: url-shortener, rate-limiter, chat-system, news-feed, file-storage
- 참조 추가: patterns, interview 플레이북, checklists
- `.claude-plugin` 마켓플레이스 구조 — 두 줄 설치
- 멀티 에이전트: Codex/Copilot 플러그인, AGENTS.md, 범용 install.sh

## 1.0.0 — 2026-08-13

- 최초 공개: 시스템 설계 레퍼런스 스킬
