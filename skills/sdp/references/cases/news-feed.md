# Case: News Feed

## Requirements

- Features: posts from followed accounts appear in a time/ranked feed;
  post creation; feed reads.
- Non-functional assumptions: 50M DAU, 10 feed loads/day → ~6k read RPS
  (peak 30k). 1M posts/day → ~12 write RPS. **Read:write 500:1 — bet
  everything on reads.** Feed load p99 < 500ms. New posts visible within
  seconds (eventual consistency fine).

## Key decisions

**1. Fan-out strategy (the heart of this problem)**

- **Push (fan-out-on-write)**: insert into every follower's feed cache at
  post time. Read = one cache lookup, ultra fast. Problem: one post by a
  10M-follower celebrity = 10M writes.
- **Pull (fan-out-on-read)**: merge followees' recent posts at read time.
  Writes free, reads expensive — self-destructs at 500:1.
- Choice: **hybrid** — push for normal users; pull for high-follower
  accounts (e.g. 100k+). Feed read = my feed cache + merge of followed
  celebrities' recent posts. Tune the threshold by fan-out queue lag.

**2. Feed storage**

- Per-user feed = Redis list/zset of post IDs only (not bodies), most
  recent ~800. Bodies live in their own cache + DB — avoids duplicate
  storage and keeps edits/deletes consistent.
- Evict feeds of inactive users (30d+) from cache; rebuild via pull on
  return — memory savings.

**3. Write path**

```
persist post (DB) → outbox → fan-out workers: fetch follower list →
push to active followers' feed caches (skip if celebrity)
```

- Fan-out is fully async — post response returns at persist. A lagging
  worker just delays feed freshness; nothing is lost (monitor queue
  depth).

**4. Ranking**

- Chronological ends at the cache. Ranked feeds: take candidates (top few
  hundred from the feed cache) and re-rank via the ranking service —
  bounding the candidate set is the key move.

## Interview gates

- Computes read:write ratio → connects it to choosing push.
- Raises the celebrity problem unprompted + hybrid answer.
- Async fan-out with explicit eventual-consistency call.
- Stores IDs, not bodies, in feeds (edit/delete duplication problem).
