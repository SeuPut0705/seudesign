# Case: Proximity Service (Yelp/Uber-like "nearby")

## Requirements

- Features: find businesses/drivers within radius R of a point; results
  ranked by distance (+ rating); business data updated by owners.
- Non-functional assumptions: 100M places, 5M searches/day peak ~500 RPS
  (read-heavy; place updates are rare). Search p99 < 200ms. Slightly
  stale data fine (minutes). For a moving-driver variant: location
  updates every few seconds from 1M drivers — write-heavy, different
  answer below.

## Key decisions

**1. Geospatial index (the heart of this problem)**

Naive `WHERE lat BETWEEN ... AND lng BETWEEN ...` full-scans or misuses
1-D indexes — 2-D proximity needs a spatial structure:

| Structure | Property |
|---|---|
| **Geohash** | encode lat/lng into a string; shared prefix ≈ nearby. Fixed grid; cells straddling boundaries need neighbor-cell checks |
| **Quadtree** | recursive 4-way split until each leaf holds ≤ K points. Adapts to density (dense cities → small cells) |
| PostGIS / R-tree | battle-tested DB extension; use when already on PostgreSQL |

- Choice for static places: **geohash in Redis/DB** — precision 6
  (~1.2km cells). Query = compute the cell + 8 neighbors, fetch candidate
  lists, exact-distance filter and rank. Simple, cacheable, no custom
  tree to operate. (PostGIS equally defensible on an existing PG stack.)

**2. Read path**

```
client → API → geohash(lat,lng,6) → Redis: cell + 8 neighbors (9 lookups)
→ exact distance filter → rank (distance, rating) → page
```

- Cell contents cached with TTL (minutes) — place data changes slowly.
- Dense areas: drop to precision 7 when a cell exceeds K candidates;
  sparse areas: widen to precision 5. Adaptive precision ≈ poor man's
  quadtree.

**3. Write path (static places)**

- Owner updates → DB (source of truth) → async invalidate/rebuild the
  affected geohash cell entries. Minutes of staleness accepted.

**4. Moving-driver variant (Uber)**

- 1M drivers × update/4s = 250k writes/s — this flips the problem to
  write-heavy.
- Keep live locations **only in memory** (Redis, sharded by geohash
  cell): `SET driver:{id} → (cell, lat, lng, ts)` + per-cell driver sets.
  No durable writes per ping — persist trips, not pings.
- Driver moves cell → remove from old cell set, add to new. TTL expires
  stale drivers (app killed).
- Match = same 9-cell read as places, against the in-memory sets.

## Interview gates

- Names a spatial index (geohash/quadtree) and why 1-D indexes fail.
- Boundary problem: searches near cell edges need neighbor cells.
- Static-place vs moving-driver split — read-heavy vs write-heavy changes
  the storage answer.
- Density skew handling (adaptive precision or quadtree).
