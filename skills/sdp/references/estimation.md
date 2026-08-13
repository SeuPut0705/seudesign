# Capacity Estimation (back-of-the-envelope)

## Unit intuition

| 2^n | Approx. | Storage unit |
|---|---|---|
| 2^10 | thousand | KB |
| 2^20 | million | MB |
| 2^30 | billion | GB |
| 2^40 | trillion | TB |
| 2^50 | quadrillion | PB |

## Latency ballparks (orders of magnitude)

| Operation | Ballpark |
|---|---|
| CPU cache reference | ~1 ns |
| Main memory reference | ~100 ns |
| Read 1MB sequentially from memory | ~0.25 ms |
| SSD random read (4KB) | ~0.15 ms |
| Read 1MB sequentially from SSD | ~1 ms |
| Round trip within a datacenter | ~0.5 ms |
| HDD seek | ~10 ms |
| Intercontinental round trip | ~150 ms |

Derived intuition:

- Throughput: memory ~GB/s ≫ SSD ~1 GB/s ≫ 1Gbps network ~100 MB/s ≫ HDD ~30 MB/s
- Memory beats disk by ~2 orders of magnitude. An in-datacenter round trip
  is ~1/300 of intercontinental.
- Conclusion: the design that minimizes disk/network round trips almost
  always wins.

## Traffic estimation procedure

1. DAU × requests per user per day ÷ 86,400 ≈ average RPS (approximate a
   day as 10^5 seconds).
2. Peak = 2-5× average (service dependent).
3. Split read vs write — their scaling strategies differ.

Example: 1M DAU × 20 requests → 2×10^7 / 86,400 ≈ 230 RPS average,
peak ~1,000 RPS.

## Storage estimation procedure

1. Item size × items created per day × retention days.
2. Multiply by replication factor (typically 3). Add 30-50% for
   indexes/metadata.

Example: 1KB events × 10M/day × 365 days ≈ 3.65TB/year; ×3 replication
≈ 11TB.

## Technique

- Round everything to powers of ten for mental math; sanity-check units at
  the end.
- If a result defies common sense (e.g. >100k RPS on one server), recheck
  the assumptions first.
- Estimates only justify design choices — replace them with measurements
  the moment you have them.
