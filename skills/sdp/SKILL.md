---
name: sdp
description: >-
  Practical system design skill. Modes: generate design docs (design), audit
  a codebase's architecture (review), run mock interviews (interview),
  estimate capacity (estimate). Use for architecture design, structural
  improvement, scalability review, technology trade-offs (CAP, caching,
  queues, DB sharding, load balancers, microservices), reliability patterns
  (circuit breakers, idempotency, rate limiting), and system design
  interview prep.
---

# sdp — System Design Skill

This is both a reference and an executable tool. When the user names a mode,
follow that workflow exactly; when a design topic comes up without a mode,
use the references alone. Always answer in **the user's conversation
language**, regardless of the language of these files.

## Modes

### `design <system description>` — generate a design doc

1. Interview for requirements: compress features to 3-5, ask for
   non-functionals (DAU, read:write ratio, latency targets, consistency
   needs). If the user doesn't know, propose reasonable assumptions and
   confirm them.
2. Compute RPS/storage with the procedure in
   [estimation.md](references/estimation.md) and show the math.
3. High-level design: component diagram (mermaid), data flow, API draft,
   data model.
4. Deep-dive 1-2 critical components + name the bottleneck + scaling path.
5. Present every choice with the rejected alternative and why, as a table.
   Save the result as a single markdown design doc (confirm the path with
   the user), following [templates/design-doc.md](references/templates/design-doc.md).
   If a similar case exists in [cases/](references/cases/), use it as the
   skeleton.

### `review [path]` — architecture audit

Read the codebase and check it against the audit items in
[checklists.md](references/checklists.md). Report as a severity-ordered
table (file:line + symptom + fix):

1. Map the structure: entry points, component boundaries, external
   dependencies (DB/cache/queue/external APIs).
2. Check: single points of failure, external calls without timeouts,
   unbounded retries, non-idempotent consumers, missing cache invalidation,
   stateful servers, N+1 queries, missing indexes, unbounded queues,
   observability gaps.
3. Prescribe the smallest fix appropriate to the current scale, using the
   [quick decision framework](#quick-decision-framework) and references.
   No premature scaling suggestions.

### `interview [problem]` — mock interview

Follow the rules in [interview.md](references/interview.md). Summary: act
as the interviewer → make the user attempt each stage first → hints only in
3 escalating levels (direction → concept → example) → finish with a rubric
scorecard + improvement points. If the user doesn't pick a problem, ask for
difficulty and choose from cases/.

### `estimate <target>` — capacity estimation

Interactive estimation using the procedure in
[estimation.md](references/estimation.md). State assumptions in a table,
show the order-of-magnitude arithmetic, and interpret what the numbers mean
for the design (single server enough? cache required? sharding when?).

## Principles (all modes)

- **No premature scaling.** Infrastructure patterns come only after the
  bottleneck is proven. Default: modular monolith + PostgreSQL + cache when
  needed.
- **Every choice is a trade-off pair** — always state what you gain and
  what you give up.
- **Minimize state.** Stateless components scale horizontally for free;
  concentrate state in one place (DB/cache/queue).
- **No design without numbers.** Start from estimates, even rough ones.

## Quick decision framework

| Symptom | First response | Then |
|---|---|---|
| Slow reads | indexes, query tuning | cache → read replicas |
| Slow writes | batch/async | partitioning → sharding |
| Traffic bursts | rate limiting, queueing | horizontal scale + LB |
| Slow external calls | timeout + retry | circuit breaker, async |
| Single point of failure | replica + health check | automatic failover |
| Duplicate-processing incident | idempotency key | outbox + idempotent consumer |

## References

- [architecture.md](references/architecture.md) — LB, reverse proxy, CDN,
  API gateway, monolith vs microservices
- [data.md](references/data.md) — DB scaling ladder, replication, sharding,
  consistent hashing, SQL/NoSQL choice, cache strategies
- [async.md](references/async.md) — queues, delivery guarantees,
  idempotency, backpressure, outbox
- [reliability.md](references/reliability.md) — availability math, CAP,
  circuit breakers, rate limiting, failover, observability
- [networking.md](references/networking.md) — DNS, TCP/UDP, RPC vs REST,
  polling/WebSocket/SSE
- [patterns.md](references/patterns.md) — saga, event sourcing, CQRS,
  distributed locks, leader election, fan-out
- [streaming.md](references/streaming.md) — batch vs stream, windows,
  watermarks, exactly-once aggregation
- [consensus.md](references/consensus.md) — quorum, Raft, linearizability,
  leases and fencing
- [probabilistic.md](references/probabilistic.md) — Bloom filter,
  HyperLogLog, Count-Min sketch
- [estimation.md](references/estimation.md) — latency numbers, estimation
  procedure
- [interview.md](references/interview.md) — interview playbook, rubric,
  common mistakes
- [checklists.md](references/checklists.md) — architecture audit +
  production readiness checklists
- [cases/](references/cases/) — worked designs: url-shortener,
  rate-limiter, chat-system, news-feed, file-storage, web-crawler,
  search-autocomplete, notification-system, proximity-service,
  video-streaming, payment-system, kv-store, collaborative-editing,
  metrics-monitoring, flash-sale, distributed-queue, unique-id-generator

## Interview answer frame

Requirements (with numbers) → high-level diagram → data model & API → name
the bottleneck → scaling plan — in that order, attaching one alternative
and the reason it lost at each step.
