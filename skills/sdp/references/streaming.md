# Batch and Stream Processing

## When each fits

| | Batch | Stream |
|---|---|---|
| Latency | minutes-hours | sub-second to seconds |
| Model | finite input, rerun whole job | unbounded input, incremental |
| Strength | throughput, simple reasoning, easy reprocessing | freshness |
| Examples | daily reports, ML training data, backfills | fraud detection, live dashboards, alerting |

- Default question: **how fresh do results actually need to be?** Hourly
  batch is dramatically simpler than streaming — don't buy streaming
  complexity for a dashboard nobody watches in real time.
- Common hybrid: stream for the live view + periodic batch as the source
  of truth that corrects drift (reconciliation).

## Streaming core concepts

- **Event time vs processing time**: when it happened vs when it arrived.
  Aggregating by arrival time corrupts results under delay/replay —
  window by event time.
- **Windows**: tumbling (fixed, non-overlapping), sliding (overlapping),
  session (gap-based). Pick by the question being asked.
- **Late events & watermarks**: a watermark declares "events before T
  have (probably) all arrived" — triggers window closing. Late arrivals
  after the watermark: drop, or emit corrections downstream.
- **State**: real aggregations need per-key state (counts, sessions) —
  it must be checkpointed; recovery replays from the last checkpoint.

## Exactly-once aggregation (the honest version)

- Transport gives at-least-once; "exactly-once" results come from
  **checkpointed state + replayable source (offsets) + idempotent or
  transactional sink**.
- Sink patterns: idempotent upsert keyed by (window, key), or
  transactional commit of results + offsets together.
- Same principle as [async.md](async.md): duplicates are inevitable;
  make their effect invisible.

## Backfill and reprocessing

- Logic bugs happen — design for reprocessing from day one: keep the raw
  event log (retention as long as storage allows), version the
  processing logic, and make sinks overwrite-safe (upserts, partitioned
  tables).
- If reprocessing is impossible, every bug becomes permanent data
  corruption.

## Ordering and partitioning

- Global ordering doesn't scale; per-key ordering (one key → one
  partition) is almost always sufficient — same insight as per-room
  ordering in [cases/chat-system.md](cases/chat-system.md).
- Partition count sets max consumer parallelism — pick generously;
  repartitioning a live topic is painful.
- Hot keys skew partitions — same mitigations as
  [patterns.md](patterns.md) hot-spot section (key salting, local
  pre-aggregation).
