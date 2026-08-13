# Distributed System Patterns

## Saga — the distributed-transaction substitute

- Problem: work spanning services (order→payment→inventory) can't share
  one transaction.
- Fix: a chain of local transactions + **compensating transactions**
  (inverse operations) on failure.
- **Choreography** (services react to events): simple with few services;
  flow becomes hard to trace.
- **Orchestration** (a coordinator directs steps): explicit flow; the
  coordinator grows complex. Prefer it beyond ~4 steps.
- Compensation is not perfect rollback (you can't unsend email) — design
  it as business-level cancellation.

## Event sourcing

- Store the **immutable log of events** instead of state; derive current
  state by replay.
- Gains: full audit history, point-in-time reconstruction, new views built
  from old data.
- Costs: schema evolution pain, replay cost (snapshots needed), a mental
  model shift.
- Unless audit is a legal requirement (finance, health), think twice.

## CQRS

- Separate write model from read model. Writes hit the normalized source
  of truth; reads hit denormalized views shaped for queries.
- Views update asynchronously (event subscription) → read model is
  eventually consistent.
- Start with the simple version (materialized views in the same DB);
  separate stores only when scale forces it.

## Distributed locks

- Goal: exactly one node performs a task (cron dedup, inventory decrement).
- Required parts: **TTL** (release even if the holder dies) + **fencing
  token** (storage rejects writes from a stale holder after expiry).
- TTL without fencing: GC pauses / network delays let two nodes hold the
  lock simultaneously.
- Prefer eliminating the problem instead: idempotency, unique constraints,
  queue serialization.

## Leader election

- One instance among many takes a role (scheduler, primary).
- Don't hand-roll — use etcd/ZooKeeper leases, or a DB-based lock table
  with TTL renewal.
- The leader renews its lease periodically and steps down on renewal
  failure (self-fencing).
- Split-brain prevention = quorum. Never bolt auto-election onto a 2-node
  cluster.

## Fan-out (follow feeds)

- **fan-out-on-write** (push): insert into every follower's timeline at
  post time. Fast reads; a celebrity's post explodes into millions of
  writes.
- **fan-out-on-read** (pull): merge followees' posts at read time. Cheap
  writes, expensive reads.
- The real answer: hybrid — push for normal users, pull-merge celebrities
  at read time.

## Time and ordering

- Wall clocks across nodes can't be trusted (drift, NTP jumps). If order
  matters, use monotonic IDs (single issuer, Snowflake-style) or logical
  clocks.
- "Last write wins" silently discards data proportional to clock skew —
  consider mergeable structures (version vectors, CRDTs) or explicit
  conflict resolution.

## Hot-spot mitigation

- Load concentrating on one key (celebrity, hot product).
- Fixes: an in-process cache layer, key replication (`key#1..N`, read a
  random replica), request coalescing (singleflight).
