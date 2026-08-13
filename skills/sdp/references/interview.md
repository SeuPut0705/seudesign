# Interview Playbook

## Session rules (interview mode)

1. After presenting the problem, **never answer first.** The user attempts
   each stage before you weigh in.
2. Hints escalate through exactly 3 levels: ① direction ("what if you
   estimated traffic first?") → ② concept ("reads dominate — what goes in
   front?") → ③ example (part of a concrete answer).
3. If the user jumps to design without asking requirements, stop them and
   return to requirements — the single biggest real-interview point loss.
4. Enforce the 45-minute pace: requirements 5' → estimation 5' →
   high-level 15' → deep dive 15' → wrap-up 5'. Flag overruns.
5. Close with the rubric scorecard + 2 strengths + 2 improvements + a
   recommended next practice problem.

## Scoring rubric (6 items × 5 points)

| Item | Full marks |
|---|---|
| Requirements | features compressed to 3-5; non-functionals pinned as numbers |
| Estimation | RPS/storage to order of magnitude, and it shapes the design |
| High-level design | role-named components, complete data flow, API/model draft |
| Deep dive | picks the riskiest component unprompted and goes deep |
| Trade-offs | states the alternative and why it lost, per choice |
| Bottleneck & scaling | names the bottleneck; scales only that point |

## Frequent problems and their gates

| Problem | Must appear |
|---|---|
| URL shortener | ID generation strategy, read:write ratio, cache, redirect latency |
| Rate limiter | algorithm rationale, distributed counters, fail-open/close |
| Chat | WebSocket connection state, presence, message ordering/dedup |
| News feed | push vs pull fan-out, celebrity problem, where ranking sits |
| File storage | chunked upload, dedup, metadata/blob separation |
| Autocomplete | prefix structure, top-K aggregation, refresh pipeline |
| Notifications | idempotency, per-channel rate limits, retries + DLQ |
| Proximity search | spatial index (geohash/quadtree), cell boundaries, moving vs static |
| Video streaming | segment-parallel transcoding, adaptive bitrate, CDN serving |
| Payment system | end-to-end idempotency, double-entry ledger, timeout ≠ failure |
| Key-value store | consistent hashing, R+W>N quorum, conflict versioning |
| Collaborative editing | OT vs CRDT, local-first apply, op log + snapshots |
| Metrics/monitoring | cardinality limit, pull vs push, downsampling |
| Flash sale | load shedding layers, atomic decrement, hold TTL |
| Message queue | log + offsets, per-partition order, acks/ISR trade-off |
| Unique ID generator | Snowflake bit budget, clock-backwards handling |

## Common mistakes (by points lost)

1. Components before requirements/numbers — silent on "who uses this and
   how much?"
2. Technology name-dropping (Kafka! Redis!) without role or reason.
3. Microservices + sharding for every problem — premature scaling with no
   numbers behind it.
4. Defensive at probing questions ("what about cache invalidation?") —
   acknowledging the trade-off is the right answer.
5. Designing only the write path (or only the read path).
6. No failure-scenario prep — "what if this node dies?" always comes.

## Answer sentence templates

- Presenting a choice: "I'd use X. Y is viable too, but given this
  requirement, Z makes X the better fit."
- Not knowing: "I don't know the internals precisely, but the requirement
  needs a tool with these properties; candidates are A/B."
- Scale branching: "At the current estimate a single DB suffices; at N×
  I'd shard, and the boundary would be this key."
