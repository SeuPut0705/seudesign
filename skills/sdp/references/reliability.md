# Reliability

## Availability math

- Serial dependencies multiply: two 99.9% services in sequence = 99.8%.
- Parallel redundancy: 1-(1-A)². Two 99.9% nodes = 99.9999% (assuming
  independent failure).
- Every added dependency multiplies availability down — count the
  dependencies on your critical path.

| Level | Allowed downtime/year |
|---|---|
| 99.9% | ~8.8 hours |
| 99.99% | ~53 minutes |
| 99.999% | ~5 minutes |

## CAP and consistency

- Network partitions are a given. During one, choose: consistency (CP,
  return errors) vs availability (AP, serve stale).
- **Strong consistency**: every read sees the latest write. Coordination
  costs latency/availability.
- **Eventual consistency**: briefly stale, converges. The default for
  high-availability systems.
- **Read-your-writes**: at minimum, users see their own writes — pin the
  session to the primary or read from primary briefly after a write.
- Vary per data class: balances strong, view counts eventual.

## The fault-isolation trio

1. **Timeouts**: every network call gets an explicit timeout. Infinite
   waits exhaust thread pools and propagate failure.
2. **Retries**: exponential backoff + jitter + attempt cap. Idempotent
   operations only. Bound with a retry budget so retry storms don't
   amplify outages.
3. **Circuit breaker**: after consecutive failures, fail fast for a
   window; half-open to probe recovery. Stops hammering a dead dependency.

+ **Fallbacks**: define the degraded behavior (cached value, default,
  reduced feature) — a breaker without a fallback just moves the error.

## Rate limiting

- Algorithms: token bucket (allows bursts; default), sliding window
  (precise), fixed window (simple; 2× burst at boundaries).
- Over-limit response: 429 + Retry-After. Key by user/IP/API key.
- Serves both self-protection (overload) and fairness (no single-tenant
  monopoly).

## Failover

- **Active-passive**: standby watches heartbeats, promotes itself.
  Downtime during promotion; unreplicated writes can be lost.
- **Active-active**: both serve traffic and provide capacity. State sync
  is complex.
- Automated failover must handle false positives (split-brain from network
  blips) — never auto-promote without quorum/fencing.

## Observability

- Three axes: **logs** (event detail) + **metrics** (numeric time series,
  alerting) + **traces** (request path).
- Attach a correlation ID to every request for cross-component tracing.
- Alert on symptoms (user impact: error rate, p99 latency), not causes;
  use dashboards to narrow causes.
- Watch p95/p99, not p50 — tail latency decides user experience.
