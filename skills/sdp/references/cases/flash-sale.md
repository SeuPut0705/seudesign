# Case: Flash Sale / Ticket Booking

## Requirements

- Features: sell K units (tickets/stock) the moment a sale opens;
  cart-hold then pay; strictly no overselling.
- Non-functional assumptions: 10M users hitting at T+0 for 10k units —
  **peak is the whole problem** (~500k RPS for seconds). Overselling =
  incident; underselling slightly (abandoned holds) = acceptable.
  Fairness matters (no bot sweep).

## Key decisions

**1. Shed load before inventory (the heart of this problem)**

```
CDN (static waiting page) → edge rate limit → queue/lottery gate
→ app (stateless) → inventory service → payment
```

- 10M requests must not reach the inventory row. Layered shedding:
  static content from CDN, per-user rate limits, then a **virtual
  waiting room** — admit users into the purchase flow at a rate the
  backend actually sustains (queue with tokens, or lottery for
  fairness). Everyone else sees a live position, not an error.

**2. Inventory decrement — correctness core**

- One row `UPDATE stock SET n = n-1 WHERE id=? AND n > 0` (atomic,
  condition in the write) or Redis Lua `DECR`-with-floor. Both prevent
  oversell; never read-then-write in two steps.
- 10k units = 10k successful decrements total — the DB easily survives
  *if* shedding upstream held. Hot-row contention is real at admission
  rates; if needed, **shard the inventory** into buckets (10×1k) and
  route randomly; rebalance leftovers at the tail.

**3. Hold → pay as a state machine with TTL**

- Decrement creates a **hold** (`held(user, unit, expires_at)`), user
  pays within e.g. 10 minutes; expiry returns the unit to stock
  (background reaper). Payment side follows
  [payment-system.md](payment-system.md) — idempotency keys, timeout ≠
  failure.
- Seat-level booking (concerts): hold is per-seat — same pattern, key =
  seat ID; seat map reads served from cache with optimistic re-check at
  hold time.

**4. Bots and fairness**

- Rate limit per account + device fingerprints + CAPTCHA at the gate;
  purchase cap per identity enforced at hold creation (unique
  constraint on user × sale).
- Lottery admission beats first-come for fairness under bot pressure —
  product decision worth stating.

**5. Degrade everything non-essential**

- During the spike: recommendations off, reviews static, search cached
  — the only write path that matters is hold/pay. Feature flags ready
  before the sale.

## Interview gates

- Load shedding layers before the inventory row; waiting room.
- Atomic conditional decrement (no read-then-write); hot-row sharding
  as the escalation.
- Hold TTL state machine; idempotent payment integration.
- Bot/fairness story (caps, lottery vs FCFS).
