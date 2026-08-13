# Case: Maps Service (Google Maps-like)

## Requirements

- Features: interactive map display, place search, routing (A→B
  directions) with live traffic ETAs.
- Non-functional assumptions: 50M DAU; map tiles dominate bandwidth;
  route computation p99 < 500ms on a continent-scale graph (~100M road
  segments); traffic refresh every few minutes.

## Key decisions

**1. Map display — pre-rendered tile pyramid**

- Never render per request: world pre-cut into **tiles** (256px, zoom
  0-20, tile count 4^z per level), addressed `z/x/y` — immutable static
  files behind a CDN ([architecture.md](../architecture.md) CDN;
  same "dumb static files scale" insight as
  [video-streaming.md](video-streaming.md)).
- Vector tiles (geometry + client rendering) over raster: smaller,
  client-side styling/rotation; raster fallback for weak clients.
- Base map changes slowly — re-render only tiles whose underlying data
  changed (spatial diff), version tile URLs for cache busting.

**2. Place search / geocoding**

- Text → candidates: inverted index ([search-engine.md](search-engine.md))
  with heavy synonym/typo handling; rank by text score × distance ×
  popularity.
- "Nearby" queries: geohash/quadtree indexing —
  [proximity-service.md](proximity-service.md) wholesale.

**3. Routing — the algorithmic core**

- Road network = weighted directed graph. Raw Dijkstra/A* on 100M edges
  per request is too slow → **precompute hierarchy**: contraction
  hierarchies (CH) — preprocessing adds shortcut edges so queries
  explore a tiny "important roads first" subgraph; continent queries
  drop to ~milliseconds.
- Trade-off to state: heavy preprocessing (hours, re-run on graph
  changes) buys query speed — classic precompute-vs-freshness
  ([search-autocomplete.md](search-autocomplete.md) same shape).
- Graph partitioned by region; cross-region routes stitch at boundary
  nodes.

**4. Live traffic**

- Anonymized GPS pings from clients → stream aggregation per road
  segment ([streaming.md](../streaming.md)) → segment speed estimates
  refreshed every 1-5min.
- Traffic changes edge *weights*, not the hierarchy: CH variants (CCH)
  separate structure from weights so traffic updates don't retrigger
  full preprocessing — say this or acknowledge periodic re-customization.
- ETA = route length over live speeds; historical speed profiles fill
  gaps (3am ≈ free flow).

**5. Client cooperation**

- Tile prefetch around viewport + on-device cache; route re-query only
  on deviation ("rerouting") rather than continuous recompute.

## Interview gates

- Tile pyramid + CDN (no per-request rendering).
- Plain Dijkstra rejected with numbers; hierarchy precompute named.
- Traffic as weight updates decoupled from structure preprocessing.
- Reuses proximity/search/streaming building blocks explicitly.
