# Case: Distributed Rate Limiter

## Requirements

- Features: N requests/minute per API key/user; 429 + Retry-After over
  limit.
- Non-functional: decision latency < 2ms; sits behind the gateway on every
  request (100k RPS); rules changeable at runtime. Slight overshoot
  (loose accuracy) acceptable.

## Key decisions

**1. Algorithm**

| Algorithm | Property | Fit |
|---|---|---|
| fixed window | one counter; 2× burst at boundaries | rough protection |
| sliding window log | exact; stores per-request timestamps | low-traffic precision |
| sliding window counter | weighted two-window average; near-exact | practical default |
| token bucket | explicit bursts (capacity + refill rate) | public APIs |

- Choice: **token bucket** — absorbs legitimate bursts while blocking
  sustained excess. Two parameters (capacity, refill rate) express policy
  clearly.

**2. Where the state lives**

- Local memory: fast but per-instance counting — N instances leak N× the
  limit.
- **Central Redis**: accurate, ~1ms round trip. Lua script makes
  read-compute-write atomic.
- Choice: Redis + Lua. 100k RPS approaches single-threaded Redis limits —
  hash-partition across a Redis cluster (per-user keys distribute
  naturally).

**3. Redis failure — fail-open vs fail-close**

- fail-open (allow): availability first, protection briefly lost.
  fail-close (429 everything): protection first, looks like a full outage.
- Choice: **fail-open + local approximate fallback** (per-instance bucket
  at limit/N) + immediate alert. A rate limiter that kills the service has
  inverted its purpose.

**4. Response**

- 429 + `Retry-After` + `X-RateLimit-Remaining` headers — give clients
  what they need to back off on their own.

## Scaling & operations

- Limits load from a config store on an interval — tune without deploys.
- Metrics: per-key 429 rate, Redis latency, fallback activations. A 429
  spike means attack or a wrong limit — both need eyes.

## Interview gates

- Algorithm rationale (why token bucket, not just its name).
- Distributed counter correctness (knows the local-leak problem).
- Defines behavior when the store dies — the fail-open/close discussion is
  the senior signal.
