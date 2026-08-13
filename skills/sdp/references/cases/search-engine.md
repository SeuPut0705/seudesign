# Case: Search Engine (site/product search scale)

## Requirements

- Features: full-text search over documents, ranked results, filters,
  near-real-time index updates.
- Non-functional assumptions: 100M documents (avg 5KB), 2k search RPS
  peak, query p99 < 300ms, new/updated docs searchable within ~10s.
  (Web-scale crawling is [web-crawler.md](web-crawler.md); this is the
  index-and-query half.)

## Key decisions

**1. Inverted index (the heart of this problem)**

- Forward scan can't meet latency — build term → posting list
  (docID, positions, term frequency):

```
"cheap flights" → tokenize/normalize → [cheap]∩[flights] posting lists
→ intersect (lists sorted by docID, skip pointers) → rank → top-K
```

- Analysis pipeline at index AND query time (same one): tokenize,
  lowercase, stem, synonyms. Mismatched pipelines = mystery zero-hit
  bugs.

**2. Ranking — two phases**

- Phase 1 (cheap, over thousands): BM25 (tf-idf family) narrows to
  ~top-500 candidates.
- Phase 2 (expensive, over hundreds): business signals (freshness,
  popularity, personalization, or a ML ranker) reorder the candidates.
- Bounding phase-2 to a candidate set is the same move as news-feed
  ranking ([news-feed.md](news-feed.md)).

**3. Index maintenance — segments**

- Indexes are built as **immutable segments**: new docs accumulate in
  memory → flush as a new segment → background merge (same
  LSM-with-compaction shape as [kv-store.md](kv-store.md) internals).
- Deletes = tombstone bitmaps, physically removed at merge.
- "Searchable in 10s" = flush/refresh interval — near-real-time, not
  transactional; say so.

**4. Scaling — shard by document**

- Each shard indexes a document subset; a query **fans out to all
  shards**, each returns local top-K, coordinator merges (scatter-
  gather). Latency = slowest shard — keep shards balanced and
  replicated (replicas double as read capacity).
- Document-partitioning beats term-partitioning (multi-term queries
  would cross shards anyway; hot terms would hot-spot).

**5. The rest of the product**

- Autocomplete is its own precomputed system
  ([search-autocomplete.md](search-autocomplete.md)).
- Index updates flow through a queue from the source-of-truth DB
  (outbox, [async.md](../async.md)) — search index is a derived view,
  rebuildable from scratch.

## Interview gates

- Inverted index + posting-list intersection (not "use Elasticsearch").
- Two-phase ranking with a bounded candidate set.
- Immutable segments + merges; near-real-time refresh honesty.
- Scatter-gather sharding; why document-partitioned.
