# Case: Web Crawler

## Requirements

- Features: start from seed URLs, follow links, fetch and store pages,
  revisit periodically.
- Non-functional assumptions: 1B pages/month ≈ 400 pages/s. Average page
  500KB → ~500TB/month raw. Politeness is mandatory — never take a target
  site down.

## Key decisions

**1. Crawl frontier (the URL queue — the heart of this problem)**

- Why a plain FIFO fails: ① requests pile onto one domain (rude) ② no
  priority (news > static docs).
- Structure: **priority queues (front) + per-domain queues (back)** —
  select by priority, then distribute into per-domain queues, each with a
  minimum request interval (respect robots.txt crawl-delay). One
  concurrent connection per domain.

**2. Two kinds of dedup**

- **URL dedup**: check before visiting — can't hold 1B URLs in a set →
  **Bloom filter** (small false-positive rate = skipping a few pages, the
  safe direction).
- **Content dedup**: different URLs, same content (mirrors, tracking
  params) — compare body hash (SimHash for near-duplicates) before
  storing.

**3. Pipeline (stage separation)**

```
frontier → downloader (DNS cache + timeouts) → parser (links, body)
→ dedup filter → store (blob: raw, metadata: for indexing) → new URLs to frontier
```

- Stages are independent workers connected by queues — scale downloaders
  (I/O-bound) separately from parsers (CPU-bound).

**4. Trap defenses**

- **Crawler traps**: pages generating infinite URLs (calendars) —
  per-domain page caps, URL depth limits.
- Parser isolation: malicious/huge HTML kills workers — size caps, parse
  timeouts, per-page failure isolation (one bad page never blocks a
  batch).
- Cache robots.txt with expiry. Identify the crawler (User-Agent).

**5. Revisit scheduling**

- Track change frequency per page (did the last N visits change?) →
  revisit fast-changing pages first. Uniform intervals waste capacity.

## Interview gates

- Politeness design in the frontier (per-domain separation + spacing) —
  missing this is close to failing.
- Dedup at 1B scale (Bloom filter memory math).
- Trap/hostile-page defenses. I/O vs CPU stage scaling.
