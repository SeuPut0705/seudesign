# Case: Stock Exchange (matching engine)

## Requirements

- Features: accept limit/market orders, match them (price-time
  priority), publish executions and market data.
- Non-functional assumptions: 100k orders/s on hot symbols,
  order-to-execution latency in **microseconds-to-low-milliseconds**,
  strict fairness (first come, first matched at a price level), zero
  lost or reordered orders. Correctness AND latency — the rare problem
  where both are absolute.

## Key decisions

**1. Single-threaded matching engine per symbol (the heart)**

- Matching must be **deterministic and fair** — concurrent matching on
  one book creates races in price-time priority. Answer: one book =
  one thread, in-memory, lock-free input via a ring buffer
  (LMAX-style). 100k/s is easy for one core when there's no I/O in the
  loop.
- Scale horizontally **by symbol** (books are independent) — never by
  splitting one book.

**2. Order book structure**

- Two sides (bids desc, asks asc): price levels in a sorted structure /
  array indexed by tick, each level a FIFO queue of orders (time
  priority). O(1) best-price access, O(log P) or O(1) inserts.
- Incoming order: cross against opposite best levels until filled or
  price no longer crosses → remainder rests in the book.

**3. Durability without killing latency — event sourcing**

- The engine is a pure function: `state × order → state × executions`.
  **Sequence and persist the input stream** (append-only log,
  replicated) *before* the engine consumes it; recovery = replay
  ([patterns.md](../patterns.md) event sourcing,
  [distributed-queue.md](distributed-queue.md) for the log).
- Hot-hot failover: a replica engine consumes the same sequenced
  stream — deterministic replay keeps it byte-identical; promotion is
  instant. The **sequencer** (single point that orders input) is the
  real critical component — replicate it with consensus
  ([consensus.md](../consensus.md)).

**4. Everything else is async fan-out**

- Executions publish to: trade feed, market data (order book deltas),
  clearing/settlement, risk. All consume the output log at their own
  pace — nothing downstream may block matching.
- Pre-trade risk checks (balance, limits) happen **before** the
  sequencer — inside the loop they'd add latency; after, they'd allow
  invalid matches.

**5. Fairness plumbing**

- Timestamping/sequencing at the gateway edge, monotonic sequence is
  the fairness guarantee ([unique-id-generator.md](unique-id-generator.md)
  clock caveats). Market data goes out to all subscribers
  simultaneously (multicast in real venues).

## Interview gates

- Single-threaded per-book engine; scale by symbol — the key insight.
- Price-time priority book structure (levels + FIFO).
- Sequence-then-replay durability; deterministic hot replica.
- Async downstream fan-out; risk checks placed before the sequencer.
