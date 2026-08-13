# Contributing

Contributions welcome — cases, references, translations, agent support.

## Ground rules

- **Content style**: every claim earns its place. Trade-offs come in pairs
  (gain/give up). Numbers over adjectives. No premature-scaling advice.
- **Language**: skill content (`skills/`, `agents/`) is English. READMEs are
  multilingual (en/ko/ja/zh) — keep all four in sync when touching one.
- **Structure**: one topic per reference file; cases follow the existing
  format (Requirements → Estimation → Key decisions → Interview gates).

## Checks before a PR

```bash
claude plugin validate .   # must pass
sh -n install.sh           # must pass
```

CI runs the same checks plus file-integrity tests.

## Adding a case study

1. Create `skills/sdp/references/cases/<name>.md` in the existing format.
2. Add it to the case list in `skills/sdp/SKILL.md` and the trees in all
   four READMEs.
3. Add a row to the "Frequent problems" table in
   `skills/sdp/references/interview.md` if it's a common interview
   question.

## Releases

Maintainers bump `.claude-plugin/plugin.json` + `gemini-extension.json`
versions together, update `CHANGELOG.md`, tag `vX.Y.Z`, and create a
GitHub release.
