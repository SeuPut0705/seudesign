# Case: Collaborative Editing (Google Docs-like)

## Requirements

- Features: multiple users edit one document simultaneously; everyone
  converges to the same content; cursors/presence; offline edits merge
  on reconnect.
- Non-functional assumptions: docs up to ~1MB text, tens of concurrent
  editors per doc, keystroke propagation < 500ms. **Convergence is
  correctness** — divergent replicas = product failure.

## Key decisions

**1. Concurrency model — OT vs CRDT (the heart of this problem)**

| | Operational Transformation (OT) | CRDT |
|---|---|---|
| Idea | transform concurrent ops against each other so order doesn't matter | data types whose merges are commutative by construction |
| Topology | needs a central server to sequence/transform | peer-to-peer capable, server optional |
| Metadata | small | per-character IDs — memory/GC overhead |
| Maturity | Docs-proven, but transform functions are notoriously tricky | modern libs (Yjs, Automerge) make it practical |

- Choice: **CRDT (Yjs-style)** for a new build — correctness by
  construction beats hand-proven transform functions, and offline/P2P
  comes free. OT remains defensible with a central server and tight
  memory budgets — name the trade-off either way.

**2. Transport and flow**

```
client edits → local apply (zero-latency UX) → broadcast ops via WebSocket
→ server relays to doc's room + appends to op log → peers merge
```

- Local-first apply is what makes typing feel instant; the network only
  reconciles.
- Server per-doc "room" (see [chat-system.md](chat-system.md) for
  connection-state handling) — doc ID routes to the same room/partition
  so op order per doc is trivial to log.

**3. Persistence**

- Op log (append-only) + periodic **snapshots** — load = latest snapshot
  + tail of ops (same replay logic as event sourcing,
  [patterns.md](../patterns.md)). Compact old ops after snapshotting.
- Version history falls out of the op log for free.

**4. Offline and reconnect**

- Client queues ops offline; on reconnect, exchanges state vectors
  ("what have you seen") and syncs the diff — CRDTs merge without
  coordination. Long-divergent branches merge correctly but possibly
  surprisingly — surface a review UI for big merges.

**5. Presence (cursors, selections)**

- Ephemeral — broadcast on a side channel, never persisted, coalesced
  (~10/s max). Losing presence data must cost nothing.

## Interview gates

- OT vs CRDT trade-off stated concretely (not just name-drops).
- Local-first apply + async reconcile (why typing stays instant).
- Op log + snapshot persistence; history for free.
- Presence as ephemeral side channel, separate from document state.
