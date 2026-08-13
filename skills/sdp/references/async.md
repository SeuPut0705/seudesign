# Asynchronous Processing

## When to use a queue

- A slow operation (video encoding, email, external API) sits inside a
  request — enqueue, respond immediately, let a worker consume.
- Ingress momentarily exceeds processing rate — the queue buffers.
- One event, many independent consumers — pub/sub.

## Delivery guarantees

- **at-most-once**: can lose, never duplicates. Rarely used.
- **at-least-once**: never loses, can duplicate. The practical default —
  which is why consumer idempotency is mandatory.
- **exactly-once**: effectively impossible in general distributed settings.
  Build "at-least-once + idempotent consumer" to get the same effect.

## Idempotency

- Processing the same message twice must equal processing it once.
- Techniques: design naturally idempotent operations (SET, upsert), or
  store processed IDs and skip duplicates (a unique constraint is the last
  line of defense).
- For external effects (payments, email), pass an idempotency key to the
  external API.

## Backpressure

- Bound the queue. On overflow: reject ingress (429/503 + Retry-After),
  shed low-priority load, or block producers.
- An unbounded queue hides failure until it erupts as OOM and hours of
  backlog. Always monitor queue depth with alerts.

## Outbox pattern

- Problem: "DB commit + queue publish" is not atomic — publish failing
  after commit loses the event.
- Fix: write the event to an outbox table in the same transaction; a
  separate relay reads it and publishes (at-least-once). Pairs with
  idempotent consumers.

## Workflow design

- Stages communicate only through message/file contracts — workers become
  independently replaceable, retryable, and scalable.
- Retries: exponential backoff + max attempts + DLQ (dead letter queue).
  Alert on DLQ growth — never drop silently.
- Long pipelines should be resumable per stage: keep intermediate outputs
  and skip completed stages.
