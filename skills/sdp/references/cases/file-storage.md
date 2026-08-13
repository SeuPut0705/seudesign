# Case: File Storage (Dropbox-like)

## Requirements

- Features: upload/download, cross-device sync, file versions, share links.
- Non-functional assumptions: 50M users × 5GB average → 250PB
  pre-replication. Files average 1MB, large ones span GBs. Uploads
  resumable. No data loss.

## Key decisions

**1. Separate metadata from blobs (the heart of this problem)**

- **Metadata** (names, tree, versions, chunk lists, permissions): RDBMS —
  needs transactions and query flexibility. Small.
- **Blobs** (content): object storage (S3-like) — you don't put 250PB in a
  database.
- Download = metadata lookup → presigned URL straight to object storage.
  App servers never relay file bytes (bandwidth bottleneck).

**2. Chunking (4MB units)**

- Resumable uploads: on failure, resend only missing chunks.
- **Deduplication**: identify chunks by content hash (SHA-256) — identical
  chunks stored once. A file uploaded by a million users stores once
  (250PB effectively becomes tens of PB).
- Edit sync: transfer only changed chunks (delta sync).

**3. Upload flow**

```
client: split file → hash chunks → present hash list to metadata service
→ server: return which chunks are missing + presigned URLs
→ client: upload only missing chunks → commit (metadata transaction, new version)
```

- Until commit, the file remains at its previous version — partial uploads
  are invisible (atomicity).

**4. Sync (across devices)**

- Each device holds a sync cursor. A change-notification channel (long
  polling or WebSocket) signals "something changed"; details come by
  pulling changes past the cursor.
- Conflicts (two offline devices edit the same file): never auto-merge —
  keep both, create a "conflicted copy", let the user resolve. LWW
  silently loses data.

**5. Versions & deletion**

- A version = a snapshot of the chunk list (chunks are immutable, so a
  version costs only the changed chunks).
- Deletes are soft + GC after retention — chunks reclaimed only at
  refcount zero.

## Interview gates

- Metadata/blob split; presigned URLs (server-relay bottleneck awareness).
- Chunking + content hashing → resume, dedup, and delta in one design.
- Conflict handling (knows LWW risk). Partial-upload atomicity.
