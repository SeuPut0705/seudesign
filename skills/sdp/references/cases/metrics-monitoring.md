# Case: Metrics & Monitoring System

## Requirements

- Features: collect metrics from thousands of services, query/graph
  them, alert on rules.
- Non-functional assumptions: 10k hosts × 1k series × point/10s ≈ **1M
  points/s ingest** — write-heavy by orders of magnitude. Recent-data
  queries dominate; alert evaluation needs fresh data (<1min). Losing a
  few points is acceptable; losing alerting is not.

## Key decisions

**1. Data model — time series**

- Series = metric name + label set (`http_requests{service=api,
  region=us}`); point = (timestamp, value).
- **Cardinality is the real capacity limit**: every unique label combo
  is a new series. A `user_id` label = cardinality bomb — enforce label
  budgets at ingestion.

**2. Pull vs push collection**

| | Pull (Prometheus-style) | Push (StatsD-style) |
|---|---|---|
| Discovery | scraper knows targets → up/down detection free | agents fire-and-forget |
| Fit | long-lived services | short-lived jobs, serverless, NAT'd edges |

- Choice: **pull for services + a push gateway for ephemeral jobs** —
  the standard hybrid. Scrape interval 10-15s.

**3. Storage — TSDB, not a general DB**

- Append-only, time-ordered, compressible: delta-of-delta timestamps +
  XOR-compressed values (Gorilla) → ~1-2 bytes/point instead of 16.
- Layout: recent data in memory blocks → flush immutable time-window
  blocks to disk (LSM-flavored; see [kv-store.md](kv-store.md)
  internals). Old blocks compact.
- **Downsampling for retention**: raw 10s for 2 weeks → 5min rollups for
  3 months → 1h for 2 years. Deleting precision, not history.

**4. Query and alerting**

- Alert rules evaluate on an interval against recent data — keep the
  hot window in memory so alerting never waits on disk.
- **Alert manager as a separate component**: dedup, grouping (one page
  for 50 instances of the same failure), silences, escalation routing.
  Alert on symptoms (error rate, p99), per
  [reliability.md](../reliability.md).
- Dashboards query rollups for long ranges — never scan raw points for
  a 90-day graph.

**5. Availability of the monitor itself**

- Monitoring must outlive what it monitors: independent infra, 2
  replicas scraping the same targets (dedup at alert manager),
  meta-monitoring ("who watches the watcher" = a dead-man's-switch
  alert that fires when the pipeline goes silent).

## Interview gates

- Names cardinality as the scaling limit (not raw point volume).
- Pull vs push trade-off with the hybrid answer.
- Compression + downsampling (why general DBs lose here).
- Alert manager dedup/grouping; monitoring's own availability story.
