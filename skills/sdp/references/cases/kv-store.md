# Case: Distributed Key-Value Store (Dynamo-style)

## Requirements

- Features: `get(key)` / `put(key, value)` at scale, tunable
  consistency.
- Non-functional assumptions: 100TB data, 100k RPS mixed read/write,
  no single point of failure, stays available under node failures and
  partitions (AP-leaning, like a session/cart store).

## Key decisions

**1. Partitioning — consistent hashing**

- Hash ring with **virtual nodes** (each physical node owns many ring
  positions) — smooths distribution and makes adding/removing nodes move
  only ~1/N of keys (see [data.md](../data.md)).

**2. Replication — N successors**

- Each key stored on N (typically 3) consecutive ring nodes, skipping
  virtual duplicates of the same physical node (and ideally spanning
  racks/zones).

**3. Tunable consistency — R + W vs N**

- Write succeeds after W acks; read queries R replicas.
- **R + W > N** → read and write sets overlap → read sees the latest
  write (quorum). R=W=2, N=3 is the common balance.
- W=1 maximizes write availability (risk: lost writes); R=1 maximizes
  read speed (risk: stale reads). State the knob and its meaning.

**4. Conflicts — versioning**

- Under partitions, two replicas can accept conflicting writes.
  Detection: **vector clocks / version vectors** (who wrote on top of
  what); concurrent versions are both kept and returned for the client
  to resolve (or last-write-wins if the product accepts silent loss —
  say so explicitly; see [patterns.md](../patterns.md) on LWW).

**5. Failure handling**

- **Sloppy quorum + hinted handoff**: if a home replica is down, write
  to the next node with a "hint"; it hands the data back when the home
  node returns. Keeps writes available during transient failures.
- **Anti-entropy with Merkle trees**: replicas periodically compare
  hash trees to find and repair divergent ranges cheaply.
- **Gossip** for membership/failure detection — no central coordinator.

**6. Node internals (single-node write path)**

- Log-structured: append to WAL → in-memory memtable → flush to
  immutable **SSTables** → background compaction. Reads check
  memtable → bloom filters → SSTables. This is why LSM stores write
  fast and read with amplification.

## Interview gates

- Consistent hashing + virtual nodes for partitioning.
- Quorum arithmetic (R+W>N) and what tuning it trades.
- Concurrent-write conflict story (version vectors vs LWW, stated
  honestly).
- At least two failure mechanisms (hinted handoff, Merkle repair,
  gossip).
