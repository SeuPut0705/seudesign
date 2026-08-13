# Case: Chat System

## Requirements

- Features: 1:1 + small groups, online presence, read receipts, push
  notifications for offline users.
- Non-functional assumptions: 10M DAU, 1M concurrent connections, 40
  msgs/user/day → ~4,600 msg/s average, peak ~20k. Delivery p99 < 500ms.
  No message loss.

## Key decisions

**1. Connections — WebSocket**

- Polling loses on both latency and load. Persistent WebSocket.
- **Connections are state**: gateway servers hold 1M concurrent
  connections (~100k per server × 10+). Separate connection management
  from chat logic — gateways stay dumb, logic stays stateless.
- Store user→gateway mapping in Redis (doubles as presence).

**2. Message flow**

```
sender → gateway → chat service: ①persist message ②look up recipient gateway
       → push via that gateway if online; enqueue push notification if not
```

- **Persist first, deliver second** — the heart of the no-loss
  requirement. Failed delivery is fine; the stored copy is the truth.

**3. Ordering and duplicates**

- Global order unnecessary; **per-room order** suffices — a monotonic
  per-room sequence (issued by the room's partition).
- Client retransmits are deduped by message ID (idempotent display).
- Receivers pull missing ranges when they detect sequence gaps —
  push+pull hybrid.

**4. Storage**

- Write-heavy (tens of thousands/s), simple query pattern (room ID + time
  range) → wide-column (Cassandra-like). Partition key = room ID,
  clustering = sequence.
- Cache recent messages per room (last N) — absorbs initial-load spikes on
  connect.

**5. Presence**

- Heartbeat (30s) + TTL — approximation is enough.
- Broadcast status changes only to friends, and batched — prevents
  presence traffic from outgrowing messages.

**6. Groups**

- Small groups (~hundreds): fan-out-on-write per member.
- Large channels are a different problem — design separately with
  fan-out-on-read + pagination.

## Interview gates

- Recognizes WebSocket connections as state (separate from stateless
  app).
- No-loss ordering (persist first). Per-room ordering mechanism.
- Offline path (push queue). Presence traffic explosion awareness.
