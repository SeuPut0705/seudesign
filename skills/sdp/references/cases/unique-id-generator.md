# Case: Distributed Unique ID Generator

## Requirements

- Features: globally unique 64-bit IDs, roughly time-ordered
  (sortable), 10k+ IDs/s across many nodes, no coordination per ID.
- Why not simpler options first (state these):

| Option | Why it fails here |
|---|---|
| DB auto-increment | single point, one write per ID, sharding breaks it |
| UUIDv4 | 128-bit, random — kills B-tree index locality, not sortable |
| Central ticket server | coordination per ID; SPOF unless batched |

## Key decisions

**1. Snowflake layout (the standard answer)**

```
64 bits = 1 sign | 41 timestamp(ms, custom epoch) | 10 machine ID | 12 sequence
```

- 41 bits of ms ≈ 69 years from your epoch; 10 bits = 1024 nodes;
  12 bits = 4096 IDs/ms/node ≈ 4M IDs/s/node ceiling.
- Time-prefix → IDs sort by creation time → **index-friendly** (new
  rows append to the right side of the B-tree) and "sort by ID ≈ sort
  by time" for free.
- Bit budget is adjustable — fewer nodes, more sequence, etc. Show the
  arithmetic for the stated requirements.

**2. Machine ID assignment**

- Must be unique per node: static config, or leased from a coordinator
  (etcd/ZooKeeper) at startup — lease renewal doubles as "two nodes
  can't share an ID" fencing (see [consensus.md](../consensus.md)).

**3. Clock problems (the senior-signal section)**

- Same-ms burst: sequence exhausts (4096) → spin-wait to next ms.
- **Clock moves backwards** (NTP step): naive generator emits
  duplicates. Options: refuse to issue until clock catches up (brief
  unavailability), or keep last-timestamp and increment sequence
  logically. Never silently reuse a past timestamp.
- Run nodes with slewing NTP (no steps) and monotonic-clock reads where
  possible; see [patterns.md](../patterns.md) on distrusting wall
  clocks.

**4. Variants worth naming**

- **Batching / segment mode**: nodes lease ranges (e.g. 100k IDs) from
  a DB — near-zero coordination, IDs only roughly ordered across
  nodes; simpler ops if strict ms-ordering isn't needed.
- **ULID/UUIDv7**: time-ordered 128-bit — right answer when 64 bits
  isn't a constraint and standard libs matter more than size.

## Interview gates

- Rejects auto-increment/UUIDv4 with reasons (index locality,
  coordination).
- Bit-budget arithmetic tied to the stated scale.
- Clock-backwards handling — the differentiator question.
- Machine-ID uniqueness mechanism (lease/fencing).
