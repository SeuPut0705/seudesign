# 용량 추정 (back-of-the-envelope)

## 2의 거듭제곱 표

| 거듭제곱 | 정확값 | 근사 | 바이트 |
|---|---|---|---|
| 10 | 1,024 | 1천 | 1 KB |
| 20 | 1,048,576 | 1백만 | 1 MB |
| 30 | 1,073,741,824 | 10억 | 1 GB |
| 40 | ~1.1조 | 1조 | 1 TB |
| 50 | ~1,125조 | 1000조 | 1 PB |

## Latency Numbers Every Programmer Should Know

```
L1 cache reference                           0.5 ns
Branch mispredict                            5   ns
L2 cache reference                           7   ns
Mutex lock/unlock                           25   ns
Main memory reference                      100   ns
Compress 1K bytes with Zippy            10,000   ns   10 us
Send 1 KB over 1 Gbps network           10,000   ns   10 us
Read 4 KB randomly from SSD            150,000   ns  150 us
Read 1 MB sequentially from memory     250,000   ns  250 us
Round trip within same datacenter      500,000   ns  500 us
Read 1 MB sequentially from SSD      1,000,000   ns    1 ms
HDD seek                            10,000,000   ns   10 ms
Read 1 MB sequentially from 1 Gbps  10,000,000   ns   10 ms
Read 1 MB sequentially from HDD     30,000,000   ns   30 ms
Send packet CA->Netherlands->CA    150,000,000   ns  150 ms
```

파생 수치:

- 메모리 순차 읽기 ~4 GB/s, SSD ~1 GB/s, 1 Gbps 네트워크 ~100 MB/s, HDD ~30 MB/s
- 디스크 왕복보다 메모리가 ~100배, 대륙 간 왕복은 데이터센터 내부의 ~300배

## 가용성 수치

| 수준 | 연간 다운타임 |
|---|---|
| 99.9% (three nines) | 8시간 46분 |
| 99.99% (four nines) | 52분 36초 |
| 99.999% (five nines) | 5분 15초 |

## 추정 요령

- 초당 요청 수: DAU × 1인당 요청 수 ÷ 86,400. 피크는 평균의 2~5배로 잡는다.
- 저장량: 항목 크기 × 생성률 × 보존 기간. 복제본 수 곱하기.
- 어림값을 10의 거듭제곱으로 반올림해 빠르게 계산하고, 마지막에 단위 재확인.
