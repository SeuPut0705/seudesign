# Consensus and Coordination

## When you actually need consensus

- Exactly-one-holder problems: leader election, distributed locks,
  membership, config that everyone must agree on.
- You almost never implement it — you *use* etcd/ZooKeeper/consul (all
  running Raft/ZAB). The skill is knowing what they guarantee and what
  they cost.

## Quorum intuition

- N nodes, majority = ⌊N/2⌋+1. Two majorities always overlap → two
  conflicting decisions can't both win. This overlap is the whole
  trick — same arithmetic as R+W>N in
  [cases/kv-store.md](cases/kv-store.md).
- N=3 tolerates 1 failure; N=5 tolerates 2. **Even counts add cost, not
  safety** (4 nodes still tolerates only 1) — run odd-sized clusters.
- 2-node "clusters" cannot form a majority after a partition — this is
  why auto-failover without quorum splits brains
  ([reliability.md](reliability.md)).

## Raft in five sentences

- Nodes are follower / candidate / leader; time divides into **terms**.
- Followers missing heartbeats become candidates and request votes; a
  majority elects the term's leader.
- All writes go through the leader, which appends to its log and
  replicates; an entry is **committed** once a majority stores it.
- A candidate can't win votes unless its log is at least as up-to-date
  as each voter's — committed entries can never be lost by election.
- Randomized election timeouts prevent split votes.

## Linearizability (what "strong consistency" means here)

- Every operation appears to happen atomically at some point between
  its start and end — reads never see older state after newer state
  was observed.
- Costs a quorum round-trip; leader-local reads need a lease or
  read-index check (a deposed leader must not serve stale reads).
- Contrast: eventual consistency
  ([reliability.md](reliability.md)) — most app data doesn't need
  linearizability; coordination metadata does.

## Leases and fencing (the practical pattern)

- A lease = time-bounded exclusive right, renewed periodically; expiry
  self-revokes even if the holder is alive-but-partitioned.
- **Fencing token** = monotonically increasing number issued with each
  lease grant; downstream storage rejects writes with an older token.
  Lease alone is not safe (GC pause outlives lease) — lease + fencing
  is (see [patterns.md](patterns.md) distributed locks).

## Operational rules of thumb

- Keep consensus clusters small (3/5) and dedicated — they coordinate;
  they don't store application data.
- Put coordination on its own failure domain: the coordinator dying
  must not take the data path down (systems should degrade to "no new
  leaders/locks", not "no reads").
- Watch: leader churn rate, proposal latency, follower lag — churn
  means network or overload, and every election is a brief write
  outage.
