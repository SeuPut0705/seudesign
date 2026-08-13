# `/sdp review` 출력 예시

> 대상: 소형 FastAPI + Celery 서비스 (실제 세션 출력 요약)

## 아키텍처 진단 결과

파악된 구조: FastAPI 앱(진입점 `app/main.py`) → PostgreSQL(SQLAlchemy),
Redis(Celery 브로커 겸 캐시), 외부 결제 API(`app/payment.py`).

| 위치 | 심각도 | 증상 | 처방 |
|---|---|---|---|
| `app/payment.py:31` | 치명 | `requests.post` 타임아웃 없음 — 결제 API 지연 시 워커 스레드 고갈 | `timeout=(3, 10)` + 재시도 2회(백오프) |
| `app/tasks.py:18` | 치명 | Celery 태스크가 멱등성 없이 결제 재시도 — 중복 결제 가능 | 멱등 키를 결제 API에 전달, 처리 ID 테이블 + unique 제약 |
| `app/models.py:44` | 높음 | `orders.user_id` 인덱스 없음 — 주문 목록 조회가 풀스캔 | `CREATE INDEX CONCURRENTLY idx_orders_user_id` |
| `app/api/orders.py:52` | 높음 | 목록 API 페이지네이션 없음 | cursor 기반 페이지네이션 (limit 기본 50) |
| `app/cache.py:12` | 중간 | 캐시 TTL 없음 — 스테일 데이터 무기한 | TTL 300s + 지터, 쓰기 시 키 삭제 |
| `app/main.py` | 중간 | 헬스체크 없음 — LB가 죽은 인스턴스 감지 불가 | `/healthz` (liveness), `/readyz` (DB ping) |

## 총평

규모(현재 ~50 RPS) 대비 구조는 적절 — 마이크로서비스 분리나 샤딩은
불필요. 치명 2건은 부하와 무관하게 사고로 이어지는 유형이라 즉시 수정
권장. 다음 병목 1순위는 주문 조회 쿼리(인덱스 후 재측정).
