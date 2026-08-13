# Networking and Communication

## DNS

- Resolves domain → IP. Results cache for the TTL (browser, OS, resolver).
- Routing policies: weighted (canary), latency-based (nearest region),
  geo (regulation/language), failover (to secondary on health-check fail).
- DNS is a cheap global traffic distributor but reacts slowly — stale
  answers persist for the TTL. For fast cutover, lower the TTL in advance
  or handle it at the LB layer.
- Trap: clients/resolvers sometimes ignore TTLs — never assume a DNS
  change moves 100% of traffic instantly.

## TCP vs UDP

| | TCP | UDP |
|---|---|---|
| Guarantees | ordering, retransmit, flow control | none (fire-and-forget) |
| Cost | handshake, connection state | minimal |
| Use | web, APIs, DBs — correctness first | streaming, games, VoIP, DNS — latency first |

- Default to TCP. UDP when "late data is worse than lost data" (a
  retransmitted old frame is useless).
- HTTP/3 (QUIC) builds reliability directly on UDP — fewer setup
  round trips.

## RPC vs REST

| | REST | RPC (gRPC etc.) |
|---|---|---|
| Model | resources + HTTP verbs | function calls |
| Contract | OpenAPI (optional) | IDL-enforced (protobuf) — type safe |
| Serialization | JSON (human readable) | binary (small, fast) |
| Fit | public APIs, browser clients | high-frequency internal calls |

- Common balance: REST outside, gRPC between internal services.
- RPC trap: network calls look like function calls, making people forget
  partial failure and latency — timeouts and retry policy remain mandatory
  on every remote call.

## Persistent connections vs polling (realtime)

| Method | Properties |
|---|---|
| short polling | periodic requests. Simple; latency = interval; wasted empty responses |
| long polling | server holds until an event. Good latency; reconnection overhead |
| WebSocket | bidirectional persistent connection. Lowest latency; connection = server state (plan for scale) |
| SSE | one-way server→client stream. Light and sufficient for notifications/feeds |

- Choose by need: bidirectional (chat) → WebSocket. Server-push only →
  SSE. Minute-level freshness → plain polling is fine — persistent
  connections aren't free.
