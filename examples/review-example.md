# `/sdp review` sample output

> Target: a small FastAPI + Celery service (condensed from a real session)

## Architecture audit

Structure found: FastAPI app (entry `app/main.py`) → PostgreSQL
(SQLAlchemy), Redis (Celery broker + cache), external payment API
(`app/payment.py`).

| Location | Severity | Symptom | Fix |
|---|---|---|---|
| `app/payment.py:31` | Critical | `requests.post` without timeout — payment API latency exhausts worker threads | `timeout=(3, 10)` + 2 retries with backoff |
| `app/tasks.py:18` | Critical | Celery task retries payment without idempotency — duplicate charges possible | pass an idempotency key to the payment API; processed-ID table + unique constraint |
| `app/models.py:44` | High | no index on `orders.user_id` — order listing is a full scan | `CREATE INDEX CONCURRENTLY idx_orders_user_id` |
| `app/api/orders.py:52` | High | list API without pagination | cursor pagination (default limit 50) |
| `app/cache.py:12` | Medium | cache without TTL — stale data forever | TTL 300s + jitter; delete keys on write |
| `app/main.py` | Medium | no health checks — LB can't evict dead instances | `/healthz` (liveness), `/readyz` (DB ping) |

## Verdict

Structure fits the current scale (~50 RPS) — no microservice split or
sharding needed. The two critical findings cause incidents regardless of
load; fix immediately. Next bottleneck: the order-listing query
(re-measure after indexing).
