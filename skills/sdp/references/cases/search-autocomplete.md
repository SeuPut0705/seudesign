# Case: Search Autocomplete

## Requirements

- Features: top-5 suggestions per prefix, popularity-weighted, reflects
  recent trends.
- Non-functional assumptions: 10M searches/day × ~4 autocomplete calls →
  peak ~2,000 RPS. Response p99 < 100ms (must keep up with typing).
  Hourly suggestion freshness is fine.

## Key decisions

**1. Lookup structure — precomputation is the key**

- Aggregating at request time is impossible (billions of log rows won't
  aggregate in 100ms) — **precompute top-K per prefix and store it**.
- Candidates:

| Structure | Property |
|---|---|
| Trie + per-node top-K cache | memory-resident, O(prefix length) lookup |
| Hash map: prefix → top-5 list | simple; prefix explosion on long queries |

- Choice: **precompute only prefixes up to N chars in a hash map** (most
  autocomplete requests are short prefixes) + filter longer prefixes from
  the shorter result. Store in Redis — one lookup, <1ms.

**2. Aggregation pipeline (write path)**

```
search logs → stream (queue) → aggregation workers: per-window counts
→ hourly batch: decay-weighted merge (recent windows weighted higher)
→ recompute per-prefix top-K → atomic swap into Redis (versioned keys)
```

- Read and aggregation paths fully separated — a lagging aggregation only
  means suggestions are an hour stale; reads are unaffected.
- Trend capture: time-decay weights (last hour ×8, last day ×2, older ×1,
  for example).

**3. Filtering**

- Banned/adult/PII patterns are excluded at aggregation time — filtering
  at query time adds latency and risks leaks.

**4. Client cooperation**

- Debounce (~150ms) cuts call volume. Cancel superseded requests (prevents
  a stale response overwriting a fresh one).
- CDN/edge caching: popular prefixes ("y", "yo") return identical
  responses — a short-TTL (60s) edge cache slashes origin load.

## Scaling

- Redis memory: millions of prefixes × top-5 × ~50B ≈ a few GB — one node
  holds it; scale traffic with replicas.
- Multilingual: separate namespaces per language (tokenization rules
  differ).

## Interview gates

- The precomputation pivot — recognizing request-time aggregation is
  impossible is the first gate.
- Read/aggregation path separation and the freshness trade-off (why
  realtime isn't needed).
- Client debounce/cancellation (end-to-end thinking).
