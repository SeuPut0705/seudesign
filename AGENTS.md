# seudesign — the sdp system design skill

This repository ships the system design skill `sdp`. Agents that auto-load
AGENTS.md (OpenCode, Cursor, etc.) get the skill through this file.

## Usage rules

When the conversation involves system design, architecture review,
scalability, technology trade-offs, capacity estimation, or system design
interviews, read [skills/sdp/SKILL.md](skills/sdp/SKILL.md) and follow its
workflows:

- `design <system>` — requirements interview → estimation → design doc
- `review [path]` — architecture audit of a codebase (file:line + severity)
- `interview [problem]` — mock interview with rubric scoring
- `estimate <target>` — interactive capacity estimation

Detailed references live in [skills/sdp/references/](skills/sdp/references/).
Always answer in the user's conversation language.

## Principles

- No premature scaling — infrastructure patterns only after the bottleneck
  is proven.
- Every choice is a trade-off pair (what you gain, what you give up).
- No design without numbers — start from estimates, even rough ones.
