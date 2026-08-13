# Case: Email Service (Gmail-like)

## Requirements

- Features: send/receive email (SMTP interop), mailbox with folders/
  labels, full-text search, spam filtering.
- Non-functional assumptions: 100M users, 50 emails received/user/day ≈
  60k msgs/s, avg 100KB (attachments separate) → ~500TB/day ingest.
  Mail must never be lost after acceptance; mailbox reads p99 < 200ms.

## Key decisions

**1. Receiving pipeline — accept fast, process async**

```
SMTP gateway (rate limit, size caps) → durable queue (accepted = owned)
→ workers: spam/virus scan → threading → indexing → mailbox store
→ notification fan-out (new-mail push)
```

- "250 OK" at SMTP means **we own it** — persist to the queue before
  acking, everything after is retryable pipeline stages
  ([async.md](../async.md); notification push =
  [notification-system.md](notification-system.md)).

**2. Storage — three separated concerns**

- **Metadata** (headers, flags, labels, thread IDs): sharded DB keyed
  by user — all mailbox-list queries are per-user, so user is the
  perfect shard key.
- **Bodies/attachments**: object storage, content-hash dedup — the
  same 5MB attachment sent to 1,000 people stores once
  ([file-storage.md](file-storage.md) chunk-dedup logic).
- **Search index**: per-user inverted index
  ([search-engine.md](search-engine.md)), sharded with the user.
  Per-user indexes stay small → fast and naturally isolated.

**3. Labels over folders**

- Message ↔ label is many-to-many metadata; "folders" are label
  filters. Moving mail = flipping rows, bodies never move. Flag
  changes (read/starred) are metadata-only writes — the hot write
  path, keep it narrow.

**4. Spam**

- Score at ingestion (separate classifier stage — cheap rules first,
  model second), quarantine to a spam label; user feedback ("not
  spam") feeds training. Outbound too: rate-limit and reputation-check
  your own senders or the platform's IPs get blacklisted.

**5. Sending — deliverability is ops, not code**

- Outbound queue with per-destination-domain rate limits and backoff
  (receivers throttle); SPF/DKIM/DMARC signing; bounce processing
  feeds back into contact validity
  ([notification-system.md](notification-system.md) permanent-failure
  handling).

## Interview gates

- Accept-then-own at SMTP; async pipeline stages.
- Metadata / blob / index separation; user as shard key everywhere.
- Attachment dedup by content hash.
- Deliverability plumbing (SPF/DKIM, per-domain throttles, bounces).
