# Case: Notification System

## Requirements

- Features: push (APNs/FCM), email, SMS through one API; user preferences
  and opt-outs; scheduled and event-triggered sends.
- Non-functional assumptions: 100M notifications/day ≈ 1,200/s average,
  campaign spikes to 100k/s. At-least-once delivery; **duplicates are the
  cardinal sin** (double "your payment failed" = support tickets). Soft
  real-time — seconds are fine.

## Key decisions

**1. Decouple accept from deliver (the heart of this problem)**

```
producers → notification service (validate, dedup, preferences) → queue per channel
→ channel workers (push / email / SMS) → provider APIs (APNs, FCM, SES, Twilio)
```

- The API accepts and enqueues — never calls providers inline. Campaign
  spikes land in queues, not on provider rate limits.
- One queue per channel: email backlog must not delay push; channels
  retry and scale independently.

**2. Idempotency (both ends)**

- Producer side: every notification carries a client-supplied
  idempotency key (e.g. `payment-failed:{payment_id}`) — dedup table with
  unique constraint drops replays at accept time.
- Worker side: at-least-once queues redeliver — workers check a
  processed-ID store before calling the provider, and pass provider-level
  dedup keys where supported (APNs collapse-id).

**3. Preferences and rate limiting per user**

- Check preferences/opt-outs at send time, not enqueue time — a user who
  opts out mid-queue must not get the message (legal requirement in
  email/SMS).
- Per-user caps (e.g. max N marketing pushes/day) — a token bucket keyed
  by user, enforced in workers. Protects users, not just infrastructure.

**4. Retries and DLQ**

- Provider failures: exponential backoff + jitter, bounded attempts,
  then DLQ. Distinguish retryable (timeout, 5xx) from permanent (invalid
  token, unsubscribed) — permanent failures update device/contact state
  instead of retrying.
- Invalid push tokens are data: feed them back to prune the device table
  (APNs/FCM report these).

**5. Tracking**

- Delivery receipts and opens flow back through an events queue into an
  analytics store — never synchronously in the send path.

## Interview gates

- Queue-per-channel decoupling; providers never called inline.
- Idempotency at both accept and deliver ends — names a concrete key.
- Preference check at send time (compliance awareness).
- Retryable vs permanent failure split; DLQ with alerting.
