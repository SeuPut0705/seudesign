# Case: Distributed Message Queue (Kafka-like log)

## Requirements

- Features: producers publish to topics; consumer groups read
  independently; replayable history.
- Non-functional assumptions: 1M msgs/s ingest, multiple consumers per
  message (fan-out), retention days-weeks, no loss once acked,
  per-key ordering.

## Key decisions

**1. Log, not queue (the heart of this problem)**

- A queue deletes on consume — one consumer set, no replay. An
  **append-only log with consumer-tracked offsets** lets N consumer
  groups read the same data at their own pace and replay from any
  point (this is what enables [streaming.md](../streaming.md)
  reprocessing).
- Broker stays dumb (store + serve by offset); consumers own their
  position. Storing per-message consumer state on the broker is what
  kills traditional brokers at scale.

**2. Partitioning for parallelism and order**

- Topic = N partitions; message key → partition (hash). **Order
  guaranteed per partition only** — per-key order via keying, global
  order abandoned deliberately.
- Partition count = max parallelism of one consumer group; choose
  generously (repartitioning live topics is painful).

**3. Replication and the ack contract**

- Each partition: 1 leader + R followers. Producers configure acks:
  `acks=1` (leader only — fast, can lose on leader death) vs
  `acks=all` with min in-sync replicas (durable). Say which and why.
- Leader failure → a follower from the in-sync set promotes (consensus
  via the cluster coordinator; see [consensus.md](../consensus.md)).
  Followers not in sync can't lead — that's the no-loss guarantee.

**4. Why it's fast**

- Sequential disk I/O (append + range reads) ≈ memory-speed via OS page
  cache; zero-copy send to sockets; producer batching + compression.
  The design wins by *never seeking*.

**5. Consumer groups and delivery**

- Group = partitions divided among members; member death →
  **rebalance** hands its partitions to survivors (brief pause —
  design consumers to tolerate it).
- Offset commit timing decides semantics: commit-after-process =
  at-least-once (default; idempotent consumers per
  [async.md](../async.md)); commit-before = at-most-once.
- Lagging consumer = growing offset gap — lag is the queue-depth metric
  to alert on.

## Interview gates

- Log + offsets vs delete-on-consume; replay as a feature.
- Per-partition ordering via keys; global order given up knowingly.
- acks / in-sync replicas trade-off; unclean leader election risk.
- Sequential I/O + page cache + batching as the performance story.
