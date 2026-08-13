# Case: Video Streaming (YouTube-like)

## Requirements

- Features: upload videos, watch (multiple qualities, seekable),
  view counts.
- Non-functional assumptions: 500k uploads/day (avg 300MB raw) ≈ 150TB/day
  ingest; 100M watches/day. Playback start < 2s; smooth under varying
  bandwidth. Uploaded video playable in minutes, not instantly.

## Key decisions

**1. Transcoding pipeline (the heart of upload)**

```
client --presigned URL--> raw storage → transcode queue
→ workers: split into segments → encode ladder (240p...4K) per segment (parallel)
→ package (HLS/DASH manifests + segments) → CDN-backed storage → mark playable
```

- Raw upload never passes through app servers (presigned, chunked,
  resumable — same as [file-storage.md](file-storage.md)).
- **Segment-level parallelism**: split video into ~10s chunks and encode
  chunks × qualities as independent queue jobs — a 2-hour video
  transcodes in near-constant wall-clock. Job = pure function
  (segment, profile) → output, so retries are trivially idempotent.
- Priority queues: first 480p rendition fast (video becomes watchable),
  higher qualities follow.

**2. Adaptive bitrate playback (the heart of watch)**

- Encode a ladder of qualities; package as HLS/DASH: a manifest lists
  qualities, each a sequence of ~4-10s segment URLs.
- **The player, not the server, adapts**: it measures throughput and
  picks the next segment's quality. Server side stays dumb static
  files — which is what makes CDN serving possible.
- Playback start: fetch manifest + first low-quality segments → upgrade.

**3. Serving — CDN does the heavy lifting**

- Segments are immutable static files → cache-perfect. Popular content
  hits ~always at the edge; origin serves the long tail.
- Popularity is Zipf — pre-warm edges for trending videos; the long tail
  can even transcode higher qualities lazily on first demand.

**4. Metadata and counts**

- Video metadata (title, status, ladder, segment map): regular DB +
  cache — tiny compared to blobs (metadata/blob split again).
- View counts at 100M/day: don't `UPDATE views = views+1` per watch —
  emit events to a stream, aggregate per window, flush periodically
  (see [streaming.md](../streaming.md)). Exact-ish is fine; the product
  needs magnitude, not a ledger.

## Interview gates

- Segment-parallel transcoding (job = segment × profile, idempotent).
- Adaptive bitrate: client-driven selection over dumb static segments.
- CDN as the serving tier; origin only for the tail.
- View counting via stream aggregation, not per-view row updates.
