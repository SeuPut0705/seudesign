# Case: URL Shortener

## Requirements

- Features: long URL → short code, redirect on visit, (optional) analytics.
- Non-functional assumptions: 10M writes/day ≈ 115 RPS; read:write = 100:1
  → ~11,500 read RPS (peak ~50k). Redirect p99 < 50ms. Codes live forever.

## Estimation

- Storage: ~500B × 10M/day × 5 years ≈ 9TB; ×3 replication ≈ 27TB — beyond
  one node, but that's year five. Start with one PostgreSQL + a sharding
  plan.
- 50k read RPS cannot hit the DB directly — cache is mandatory.

## Key decisions

**1. Code generation — candidates**

| Approach | Pros | Cons |
|---|---|---|
| Global counter + base62 | short, no collisions | issuer is a SPOF, sequence leaks |
| Hash(URL) truncated | stateless | collision handling; same URL → same code |
| Random + unique retry | simple, unpredictable | retries grow as space fills |

- Choice: **random 7-char base62** (62^7 ≈ 3.5 trillion — 5-year volume of
  18B is 0.5% of the space, collisions rare) + DB unique constraint with
  retry. Keeps the issuing service stateless.

**2. Redirect path (read-dominated)**

```
client → LB → app (stateless) → Redis (cache-aside, TTL+jitter)
                                └miss→ PostgreSQL
```

- Popular URLs follow a Zipf distribution — a small head takes most
  traffic; expect 90%+ cache hit rate. 301 (permanent, browser-cached) vs
  302 (allows analytics) — choose 302 if analytics matter.

**3. Analytics (optional)**

- No synchronous aggregation in the redirect path — publish click events
  to a queue; workers batch-aggregate. Protecting redirect latency wins.

## Scaling path

1. Now: one PG + Redis + 2 stateless app nodes.
2. Read growth: Redis cluster + read replicas.
3. Storage ceiling: hash-shard by code (random codes distribute evenly —
   a good shard key).

## Interview gates

- States the read:write ratio first. Doesn't send 50k RPS to the DB
  uncached.
- 301/302 trade-off. Collision/SPOF discussion for code generation.
