# PROJECT_SNAPSHOT.md
> **프로젝트명**: LLM & MacBookPro M4Pro (2026 개인공부)
> **최종 업데이트**: 2026-03-04 | **버전**: vNext
> **관리 규칙**: 이 파일은 Claude가 항상 최신으로 유지. 변경 시 버전/날짜 갱신 필수.

---

## 1. 목표 (Objective)

| 구분 | 내용 |
|---|---|
| **최종 목표** | Mac 노트북 상태를 실시간 수집 → 파이프라인 → 웹 UI 감시 + LLM 자연어 조회/제어 |
| **올해 목표** | 실행 가능한 PoC를 Phase 4까지 단계별 완주 |
| **학습 목표** | LLM / Kafka / Airflow / Python / 서버개발 심화 / ETL·배치 직접 구현 |

---

## 2. 현재 상태 (Current Status)

| 항목 | 내용 |
|---|---|
| **현재 Phase** | Phase 0 — 진행 중 |
| **완료된 것** | 프로젝트 정의, 협업 규칙 확정, 스키마 v0, 문서 구조, GitHub repo 생성, MariaDB 컨테이너, Python Agent 스케줄러 구현 |
| **진행 중** | Phase 0 — 0-2-4 MariaDB INSERT 구현 준비 중 |
| **다음 액션** | `0-2-4` Python Agent → MariaDB INSERT 구현 |

---

## 3. 완주 원칙 (Principles)

| # | 원칙 |
|---|---|
| 1 | Phase 0 DoD = `docker-compose up` → agent 실행 → DB row count 증가 → 그래프 1개 확인 |
| 2 | 한 Phase에 새로운 큰 기술 요소 1개만 추가 |

---

## 4. 협업 규칙 (Collaboration Rules v1)

| 역할 | 담당 | 도구 |
|---|---|---|
| **Claude** | 문서 작성/갱신, 스키마 확정, ADR, 로드맵 유지 | Claude.ai |
| **ChatGPT** | 실행 코드, docker-compose, agent, API, UI, 디버깅 | ChatGPT |
| **PEGASUS** | merge, 실행, 결과(로그/스크린샷) 공유 | GitHub Desktop + Terminal |

> **SSOT**: `docs/PROJECT_SNAPSHOT.md` — 매 세션 시작 전 이 파일을 LLM에 첨부한다.

---

## 5. 아키텍처 요약 (Architecture Overview)

```
[Mac Agent(Python)]
    │ Core metrics (CPU/MEM/DISK/NET/BAT/PROC)
    ▼
[Phase 0~1] → MariaDB (직접 적재)
[Phase 2]   → Apache Druid (시계열)
[Phase 3A]  → Kafka → Druid  (실시간 스트리밍)
[Phase 3B]  → Airflow (배치/집계)
[Phase 4]   → LLM API (요약/조회/제어) + WebSocket
    │
    ▼
[Spring Backend] → [React Frontend]
    ├── 실시간 대시보드 (SSE → Phase 1, WS → Phase 4)
    ├── 이력 조회 + 기간 필터
    └── 알람 + LLM 자연어 인터페이스
```

> 상세 Mermaid → `docs/architecture.md` 참조

---

## 6. 스키마 v0 요약 (Schema Summary)

> 상세 정의 → `docs/schema_v0.md` 참조

**Druid (시계열 원본)**

| 테이블 | 핵심 컬럼 |
|---|---|
| `metric_cpu` | ts, device_id, core_id, usage_pct, freq_mhz |
| `metric_memory` | ts, device_id, total_gb, used_gb, swap_used_gb |
| `metric_disk` | ts, device_id, mount, read_mbps, write_mbps, used_pct |
| `metric_network` | ts, device_id, iface, rx_mbps, tx_mbps |
| `metric_battery` | ts, device_id, pct, is_charging, cycle_count |
| `metric_process` | ts, device_id, pid, name, cpu_pct, mem_mb |

**MariaDB (메타/알람)**

| 테이블 | 용도 |
|---|---|
| `device` | 장비 등록 정보 |
| `alarm_rule` | 알람 임계치 룰 |
| `alarm_event` | 알람 발생/해소 이력 |

---

## 7. TODO Top 10

| # | 작업 | Phase | 담당 | 상태 |
|---|---|---|---|---|
| 1 | docker-compose.yml (MariaDB) 작성 | 0-1-2 | GPT | 🔲 |
| 2 | init.sql DDL (device, alarm_rule, alarm_event) | 0-1-3 | GPT | 🔲 |
| 3 | DBeaver 연결 확인 | 0-1-4 | PEGASUS | 🔲 |
| 4 | Python venv + psutil 설치 | 0-2-1 | GPT | 🔲 |
| 5 | Mac Agent v0 (Core 6종 수집 → MariaDB) | 0-2-2~4 | GPT | 🔲 |
| 6 | Spring Boot 프로젝트 생성 + MariaDB 연결 | 0-3-1~2 | GPT | 🔲 |
| 7 | REST API v0 (최신 메트릭 조회) | 0-3-3 | GPT | 🔲 |
| 8 | React 프로젝트 생성 + API polling | 0-4-1~2 | GPT | 🔲 |
| 9 | CPU 그래프 1개 (Recharts) | 0-4-3 | GPT | 🔲 |
| 10 | Phase 0 DoD 최종 확인 | 0 | PEGASUS | 🔲 |

---

## 8. 결정 기록 요약 (ADR Summary)

> 상세 → `docs/adr.md` 참조

| # | 결정 | 날짜 |
|---|---|---|
| ADR-001 | GitHub SSOT, Claude=문서, GPT=코드 역할 분리 | 2026-03-04 |
| ADR-002 | Phase 0은 Kafka 없이 Agent → MariaDB 직접 적재 | 2026-03-04 |
| ADR-003 | 수집 주기: Fast(CPU/MEM/NET/BAT) 5초, Slow(DISK/PROC) 15초 | 2026-03-04 |
| ADR-004 | Process TopN: CPU 기준 상위 10개 | 2026-03-04 |
| ADR-005 | Windows 노트북은 Phase 3A Kafka 도입 시점에 2번째 에이전트로 추가 | 2026-03-04 |
| ADR-006 | Phase 1 실시간은 SSE만, WebSocket은 Phase 4 UI 컨트롤로 미룸 | 2026-03-04 |
| ADR-007 | Phase 3을 3A(Kafka)와 3B(Airflow)로 분리 | 2026-03-04 |