# PROJECT_SNAPSHOT.md
> **프로젝트명**: LLM & MacBookPro M4Pro (2026 개인공부)
> **최종 업데이트**: 2026-03-04 | **버전**: v0.1.0
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
| **현재 Phase** | Phase 0 — 착수 준비 중 |
| **완료된 것** | 프로젝트 정의, 협업 규칙 확정, 스키마 v0 초안, 문서 구조 생성 |
| **진행 중** | GitHub repo 생성, docker-compose(MariaDB) 작성 |
| **다음 액션** | GPT에게 docker-compose.yml + Mac Agent(Core) 코드 요청 |

---

## 3. 협업 규칙 (Collaboration Rules v1)

| 역할 | 담당 | 도구 |
|---|---|---|
| **Claude** | 문서 작성/갱신, 스키마 확정, ADR, GitHub Issues 생성 | Claude.ai |
| **ChatGPT** | 실행 코드, docker-compose, agent, API, UI, 디버깅 | ChatGPT |
| **사용자(나)** | merge, 실행, 결과(로그/스크린샷) 공유 | GitHub + Terminal |

> **SSOT**: `docs/PROJECT_SNAPSHOT.md` — 매 세션 시작 전 이 파일을 LLM에 첨부한다.

---

## 4. 아키텍처 요약 (Architecture Overview)

```
[Mac Agent(Python)]
    │ Core metrics (CPU/MEM/DISK/NET/BAT/PROC)
    ▼
[Phase 0~1] → MariaDB (직접 적재)
[Phase 2]   → Apache Druid (시계열)
[Phase 3]   → Kafka → Druid  +  Airflow (배치/집계)
[Phase 4]   → LLM API (요약/조회/제어)
    │
    ▼
[Spring API] → [Web UI (React)]
                  ├── 실시간 대시보드 (SSE/WS)
                  ├── 이력 조회 + 기간 필터
                  └── 알람 + LLM 자연어 인터페이스
```

> 상세 Mermaid 다이어그램 → `docs/architecture.md` 참조

---

## 5. 스키마 v0 요약 (Schema Summary)

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

## 6. TODO Top 10

| # | 작업 | Phase | 담당 | 상태 |
|---|---|---|---|---|
| 1 | GitHub repo 생성 + 폴더 구조 커밋 | 0 | 사용자 | 🔲 |
| 2 | docker-compose.yml (MariaDB) 작성 | 0 | GPT | 🔲 |
| 3 | MariaDB DDL (device, alarm_rule, alarm_event) | 0 | GPT | 🔲 |
| 4 | Mac Agent v0 (psutil, Core 6종 수집 → MariaDB) | 0 | GPT | 🔲 |
| 5 | Spring API v0 (최신 메트릭 조회 엔드포인트) | 1 | GPT | 🔲 |
| 6 | Web UI v0 (폴링 + 그래프 1~2개) | 1 | GPT | 🔲 |
| 7 | SSE/WS 실시간 갱신 + 기간 필터 | 1 | GPT | 🔲 |
| 8 | Druid docker-compose + ingestion spec | 2 | GPT | 🔲 |
| 9 | Kafka + Airflow 도입 | 3 | GPT | 🔲 |
| 10 | LLM 연동 (요약/조회) | 4 | GPT+Claude | 🔲 |

---

## 7. 결정 기록 요약 (ADR Summary)

> 상세 → `docs/adr.md` 참조

| # | 결정 | 날짜 |
|---|---|---|
| ADR-001 | GitHub를 SSOT로, Claude=문서, GPT=코드 역할 분리 | 2026-03-04 |
| ADR-002 | Phase 0은 Kafka 없이 Agent → MariaDB 직접 적재로 시작 | 2026-03-04 |
| ADR-003 | 수집 주기: Core 메트릭 5초, Process TopN 15초 | 2026-03-04 |
| ADR-004 | Process TopN 기준: CPU 기준 상위 10개 | 2026-03-04 |
