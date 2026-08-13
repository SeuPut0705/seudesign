# Case: Payment System

## Requirements

- Features: charge a customer via an external PSP (Stripe-like), record
  balances, pay out to merchants, reconcile.
- Non-functional assumptions: 1M payments/day ≈ 12 RPS — **tiny traffic,
  maximum correctness**. Zero tolerance for double charges or lost money.
  Consistency over availability (CP): failing a payment is acceptable;
  charging twice is not.

## Key decisions

**1. Idempotency end to end (the heart of this problem)**

- Client → API: every payment request carries an idempotency key
  (`order_id`); unique constraint returns the original result on replay.
- API → PSP: forward the same key (PSPs support idempotency keys) —
  a timeout after the PSP charged must not become a second charge on
  retry.
- Timeout ≠ failure: the PSP may have succeeded. Never auto-retry a
  payment on timeout as if it failed — mark **pending-unknown** and
  resolve via the PSP's query API or webhook.

**2. Double-entry ledger**

- Every money movement = two entries (debit one account, credit
  another); the sum of all entries is always zero. Balance = sum of an
  account's entries.
- Ledger is **append-only** — corrections are new reversing entries,
  never updates or deletes. This is the audit trail regulators and
  debugging demand.
- Wallet "current balance" tables are a derived cache of the ledger, not
  the truth.

**3. State machine, not flags**

- Payment lifecycle: `created → pending → succeeded | failed →
  (refunded)` — explicit state machine with legal transitions enforced
  in one place. Boolean soup (`is_paid`, `is_failed`, `retried`)
  guarantees impossible states.
- Transitions are persisted before side effects (outbox pattern for
  events like "payment succeeded → release order").

**4. Webhooks (PSP → us)**

- At-least-once and out-of-order: handlers must be idempotent (event ID
  dedup) and tolerate late/duplicate events. Verify signatures.
- Don't trust webhooks alone — a periodic **reconciliation** job pulls
  the PSP's records and diffs against the ledger. Mismatches page a
  human; money bugs don't self-heal.

**5. Retries and exactly-once effect**

- Retry only reads and idempotent-keyed writes, with backoff and caps.
- The combination — idempotency keys + append-only ledger + state
  machine + reconciliation — is what "exactly-once money movement"
  actually means in practice.

## Interview gates

- Idempotency key flows through client → API → PSP; timeout treated as
  unknown, not failure.
- Double-entry, append-only ledger; balances derived.
- Webhook idempotency + signature + reconciliation job.
- Chooses CP explicitly (fail closed on partitions).
