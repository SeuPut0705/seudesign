# Case: Ad Click Aggregation

## Requirements

- Features: count clicks per ad (minute granularity) for billing and
  dashboards; top-N ads per window; support late data and recounts.
- Non-functional assumptions: 1B clicks/day ≈ 12k/s average, 100k/s
  peak. **Billing-grade correctness** — advertisers pay per click, so
  duplicates and losses are money bugs. Dashboard freshness ~1min;
  billing finality can lag hours.

## Key decisions

**1. Two-path honesty: fast approximate + slow exact**

```
click → collector → log/queue (source of truth, retained weeks)
   ├→ streaming aggregation → minute counts → dashboard store (fresh, ~exact)
   └→ hourly/daily batch over the raw log → billing table (exact, final)
```

- Stream feeds dashboards; **batch over the immutable raw log is the
  billing truth** and corrects the stream (lambda-style
  reconciliation — see [streaming.md](../streaming.md)). Disputes
  replay the log.

**2. Exactly-once accounting**

- Click IDs generated at the edge
  ([unique-id-generator.md](unique-id-generator.md)); dedup in the
  stream (state keyed by click ID within a window) and in batch
  (GROUP BY click_id). At-least-once transport + idempotent
  aggregation = exactly-once effect ([async.md](../async.md)).
- Fraud/bot filtering is a separate classifier stage before counting —
  filtered clicks are logged (auditable) but not billed.

**3. Late events and watermarks**

- Clicks arrive late (mobile offline, retries). Window by **event
  time**; watermark closes windows for the dashboard; batch recount
  emits **corrections** for anything later. Billing uses the final
  batch — never charge off a watermark-closed stream number.

**4. Hot keys — viral ads**

- One ad taking 50k/s skews a partition. Pre-aggregate per collector
  instance (local partial counts flushed every second), or salt the
  key (`ad123#0..9`) and re-merge — same hot-spot playbook as
  [patterns.md](../patterns.md).

**5. Storage layout**

- Minute counts: (ad_id, minute) → count, partitioned by time —
  append-mostly, TTL to rollups like
  [metrics-monitoring.md](metrics-monitoring.md) downsampling.
- Top-N per window: heap over the minute table, or Count-Min + heap
  when memory-bound ([probabilistic.md](../probabilistic.md)) —
  dashboards only; never billing.

## Interview gates

- Raw immutable log as source of truth; stream = fresh, batch = final.
- Dedup by click ID at aggregation, not just transport promises.
- Event-time windows + corrections; billing off final data only.
- Hot-ad mitigation (local pre-aggregation / key salting).
