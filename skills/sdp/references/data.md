# Data Layer

## DB scaling ladder (cheapest first, one rung at a time)

1. **Tuning**: slow-query log → indexes → kill N+1 → connection pool.
2. **Cache**: put repeated reads in a cache. Most systems stop here.
3. **Read replicas**: for high read:write ratios. Replication lag can break
   read-your-writes — route a user's own reads to the primary.
4. **Vertical scaling**: a bigger machine. Zero management cost, hard ceiling.
5. **Partitioning / federation**: table partitions, per-domain databases.
6. **Sharding**: last resort. A bad key choice means resharding hell.

## Replication

- **Async**: fast writes; recent writes can be lost on failover. The default.
- **Sync**: no loss, higher write latency. For money/inventory data.
- **Multi-primary**: needs write-conflict resolution. Avoid unless
  geo-distributed.

## Sharding

- Shard key requirements: uniform distribution + most queries hit a single
  shard.
- Traps: hot keys (celebrity pile-up), cross-shard joins/transactions,
  rebalancing.
- **Consistent hashing**: limits key movement to 1/N when nodes change;
  virtual nodes smooth the distribution. The standard technique for cache
  clusters and shard routing.

## SQL vs NoSQL

| Condition | Choice |
|---|---|
| Joins, transactions, integrity | RDBMS (PostgreSQL by default) |
| Ultra-fast reads/writes by single key, TTL | key-value (Redis) |
| Flexible schema, document-shaped reads | document (MongoDB) |
| Maximum write throughput, time series | wide-column (Cassandra) |
| Relationship traversal is the query | graph (Neo4j) |

- Rule: start with PostgreSQL; peel off specific patterns to specialized
  stores only when proven. Preemptive NoSQL adoption is usually regretted.

## Caching

- Layers: browser → CDN → app cache (Redis/Memcached) → DB buffers.
- **Cache-aside** (default): app loads from DB on miss and populates the
  cache. Requires tolerating staleness.
- **Write-through**: writes go through the cache synchronously. Reads
  always fresh; writes slower.
- **Write-behind**: write to cache, flush async. Fast; cache failure = data
  loss.
- Invalidation: start with TTL → delete keys on write (delete, not update)
  → versioned keys.
- **Cache stampede**: a hot key expires and requests pile onto the DB.
  Fixes: TTL jitter, lock/singleflight so only one request reloads,
  background refresh.
- A cache is a performance optimization, not a consistency tool — the
  system must still work with the cache gone.

## Denormalization

- Paying the read-path join cost at write time (duplicate storage).
- Only when read:write is extreme and joins are the proven bottleneck. The
  write path takes on responsibility for updating every copy — a missed
  copy is a silent data bug.
