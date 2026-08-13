# Checklists

## Architecture audit (for review mode)

Report each finding with real evidence (file:line) and severity.
Smallest fix for the current scale first — premature-scaling suggestions
count against the review.

### Critical (direct incident/data-loss paths)

- [ ] External calls without timeouts (HTTP clients, DB, queues) — thread
      exhaustion path
- [ ] Non-idempotent payment/external effects combined with retries —
      duplicate-execution incidents
- [ ] Multi-table updates without a transaction — inconsistency on partial
      failure
- [ ] Single point of failure: sole DB/cache/queue instance with no
      recovery plan
- [ ] Hardcoded secrets/credentials

### High (will break under load growth)

- [ ] N+1 queries; missing indexes on frequently queried columns
- [ ] Unbounded retries, or retries without backoff — outage amplifiers
- [ ] Unbounded queues/buffers/in-memory caches — OOM paths
- [ ] Server-local state (sessions, uploads) — blocks horizontal scaling
- [ ] List APIs without pagination

### Medium (operational quality)

- [ ] Caches without TTL/invalidation strategy
- [ ] External APIs without circuit breaker/fallback
- [ ] No ingress rate limiting on public endpoints
- [ ] No structured logs / correlation IDs — untraceable incidents
- [ ] No error-rate/p99 metrics or alerts
- [ ] Irreversible migrations

### Design quality

- [ ] Component boundaries visible in file/module structure
- [ ] Explicit contracts between stages (files/messages/APIs)
- [ ] Domain logic separated from I/O — testable
- [ ] Config separated from code, injectable per environment

## Production readiness (pre-launch)

### Reliability

- [ ] Every external call: timeout + bounded retries + defined failure
      behavior
- [ ] Core function survives (degraded) when any one dependency dies
- [ ] Health checks (liveness vs readiness separated)
- [ ] Backups exist + **restore rehearsed** (an untested backup is not a
      backup)

### Scale

- [ ] Load-tested at 5× current traffic estimate
- [ ] The #1 next bottleneck is documented
- [ ] Statelessness verified — two instances run correctly

### Observability

- [ ] Dashboard: request rate, error rate, p50/p99 latency, queue depth,
      DB connections
- [ ] Alerts only on user-impact metrics, wired to an owner and runbook
- [ ] Deployed version identifiable (which commit is live, instantly)

### Security

- [ ] All input validated; parameterized queries
- [ ] TLS in transit; sensitive data encrypted at rest
- [ ] Least privilege (DB accounts, IAM, API key scopes)
- [ ] Dependency vulnerability scan passes
