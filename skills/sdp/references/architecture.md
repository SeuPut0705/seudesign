# Architecture Components

## Load balancer

- Roles: distribute requests, evict dead servers via health checks, TLS
  termination, session affinity.
- **L4**: TCP-level. Fast and simple, can't inspect content.
- **L7**: routes on HTTP content (path, headers). Flexible, costs more.
- Policies: round-robin, least-connections, hash (affinity), weighted.
- The LB itself must not become the SPOF — pair it (active-passive + VRRP,
  or multiple DNS A records).

## Reverse proxy

- Valuable even with one server: TLS termination, response caching,
  gzip/br compression, static file serving, hiding internal topology,
  request filtering.
- Overlaps with LB — at small scale one nginx/Caddy does both.

## CDN

- Serve static assets (images, JS, video) from the edge; cuts origin load
  and latency at once.
- **Pull** (cache on first request): operationally simple; use this by
  default.
- **Push** (upload on deploy): for rarely-changing, large assets.
- Invalidate via URL versioning (`app.js?v=abc123` or hashed filenames) —
  don't rely on purge APIs.

## API gateway

- Single entry point between clients and internal services: auth, rate
  limiting, routing, request/response transforms, aggregation.
- Pointless without microservices — in a monolith, middleware does this.

## Monolith vs microservices

- **Default to a modular monolith.** A monolith with clean module
  boundaries can be split along those lines later. Microservices with
  messy boundaries are a distributed monolith — the worst outcome.
- Splitting is justified when: teams block each other on deploys,
  components have very different scaling needs, or fault isolation is
  required.
- The costs: function calls become network calls (latency + partial
  failure), distributed transactions, service discovery, deploy/observability
  infra.
- Splitting web tier from worker tier is the cheap separation to do first.

## Statelessness

- The precondition for horizontal scaling. No sessions or files on server
  disk.
- Sessions → central store (Redis) or signed tokens (JWT). Files → object
  storage (S3-like).
- Test: if any server can die during a deploy with zero user impact,
  you're stateless.
