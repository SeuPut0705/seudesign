# Probabilistic Data Structures

Exactness at scale is often unaffordable; bounded error for orders of
magnitude less memory is the trade. Always state the error you accepted.

## Bloom filter — "have I seen this?"

- Set membership with **false positives, never false negatives** ("no"
  is certain, "yes" is probable).
- k hash functions set k bits; ~10 bits/element ≈ 1% FP rate — 1B URLs
  in ~1.2GB instead of a 40GB+ hash set
  ([cases/web-crawler.md](cases/web-crawler.md)).
- Can't delete (counting Bloom variant can, at 4× memory). Also inside
  LSM stores to skip SSTables ([cases/kv-store.md](cases/kv-store.md)).
- Design question to answer: which direction of error is safe? Crawler
  skipping a page: safe. Payment dedup: NOT safe — Bloom pre-filter +
  exact check, never Bloom alone.

## HyperLogLog — "how many distinct?"

- Cardinality estimation: count distinct users/IPs in **~12KB per
  counter** with ~0.8% error (vs GBs for an exact set).
- Intuition: hash values' longest leading-zero run estimates log(N);
  thousands of sub-registers averaged.
- Killer feature: **HLLs merge** (bitwise max) — count per hour, union
  into day/month for free; distributed nodes merge without shipping
  raw data. Redis `PFADD/PFCOUNT/PFMERGE`.

## Count-Min Sketch — "how often does X occur?"

- Frequency table in fixed memory: d rows × w counters, item increments
  one counter per row, estimate = min across rows.
- **Overestimates only** (collisions add) — combine with a small heap
  to keep top-K: heavy hitters / trending topics / hot keys in KBs
  ([cases/search-autocomplete.md](cases/search-autocomplete.md)
  aggregation, hot-key detection in
  [patterns.md](patterns.md)).

## Choosing

| Question | Structure | Error direction |
|---|---|---|
| Seen before? | Bloom filter | false "yes" |
| How many distinct? | HyperLogLog | ±~1% |
| How often / top-K? | Count-Min + heap | overcount |

Rule: probabilistic structures are for *filters, metrics, and
candidates* — anything user-visible or money-adjacent gets exact
verification behind the probabilistic front.
