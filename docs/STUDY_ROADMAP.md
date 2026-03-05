# STUDY_ROADMAP.md — 학습 로드맵
> **버전**: vNext | **최종 업데이트**: 2026-03-04
> **관리**: Claude 유지
> **완주 원칙**: ① Phase 0 DoD = DB에 데이터 쌓이는 것 확인 ② 한 Phase에 새 큰 요소 1개만
> **범례**: 🔲 미시작 / 🔄 진행중 / ✅ 완료 / ⏭ 스킵(나중에)

---

## Phase 0 — MVP (Agent → MariaDB → 그래프 1개)
> **Phase DoD**: `docker-compose up` → agent 실행 → DB row count 증가 → 브라우저 그래프 1개 확인

### 1. 환경 구성
| # | 항목 | 학습 내용 | DoD | 상태 |
|---|---|---|---|---|
| 0-1-1 | Docker Desktop 설치 (Mac) | Docker 기본 개념, Apple Silicon 호환 | `docker ps` 정상 출력 | ✅ |
| 0-1-2 | docker-compose 작성 | yml 문법, 서비스/볼륨/네트워크 기본 | `docker-compose up` 후 MariaDB 컨테이너 Running | 🔲 |
| 0-1-3 | MariaDB 컨테이너 실행 | 포트 바인딩, 초기화 스크립트(init.sql) | DBeaver에서 3306 접속 + 테이블 3개 생성 확인 | 🔲 |
| 0-1-4 | DBeaver 연결 | DB 클라이언트 기본 사용법 | device/alarm_rule/alarm_event 테이블 조회 성공 | 🔲 |

### 2. Python Agent (Mac 수집)
| # | 항목 | 학습 내용 | DoD | 상태 |
|---|---|---|---|---|
| 0-2-1 | Python 가상환경 설정 | venv / pip, 의존성 관리 | `pip list`에 psutil, PyMySQL 확인 | 🔲 |
| 0-2-2 | psutil 기본 사용법 | CPU/메모리/디스크/네트워크/배터리/프로세스 수집 API | 터미널에서 6종 수집값 print 출력 확인 | 🔲 |
| 0-2-3 | 수집 스케줄러 구현 | threading / schedule, 주기별 실행 (Fast 5초/Slow 15초) | 30초 실행 후 Fast 6회·Slow 2회 로그 확인 | 🔲 |
| 0-2-4 | MariaDB INSERT 구현 | PyMySQL 연결, INSERT 쿼리 | DBeaver에서 row count 증가 확인 | 🔲 |

### 3. Backend (Spring Boot)
| # | 항목 | 학습 내용 | DoD | 상태 |
|---|---|---|---|---|
| 0-3-1 | Spring Boot 프로젝트 생성 | Spring Initializr, 의존성 구성 | `mvn spring-boot:run` 정상 기동 | 🔲 |
| 0-3-2 | MariaDB 연결 설정 | application.yml, JPA/MyBatis 선택 | 앱 기동 시 DB 연결 오류 없음 | 🔲 |
| 0-3-3 | REST API v0 구현 | @RestController, 최신 메트릭 조회 | `GET /api/metrics/latest` curl 응답 JSON 확인 | 🔲 |

### 4. Frontend (React)
| # | 항목 | 학습 내용 | DoD | 상태 |
|---|---|---|---|---|
| 0-4-1 | React 프로젝트 생성 | Vite, 기본 구조 | `npm run dev` 브라우저 기본 화면 확인 | 🔲 |
| 0-4-2 | API 호출 + polling | axios, 5초 polling | Network 탭에서 5초마다 API 호출 확인 | 🔲 |
| 0-4-3 | CPU 그래프 1개 | Recharts 시계열 LineChart | 브라우저에서 CPU 그래프 실시간 갱신 확인 | 🔲 |

---

## Phase 1 — 실시간(SSE) + 이력 조회 + 알람
> **Phase DoD**: SSE로 그래프 실시간 갱신 + 기간 필터 조회 + 알람 1개 발생/표시 확인
> **새 요소 1개**: SSE (Server-Sent Events)
> ※ WebSocket은 Phase 4 LLM UI 컨트롤 시점에 도입

### 5. 실시간 통신 (SSE)
| # | 항목 | 학습 내용 | 상태 |
|---|---|---|---|
| 1-5-1 | SSE 개념 이해 | SSE vs Polling vs WebSocket 차이, 언제 무엇을 쓰는가 | 🔲 |
| 1-5-2 | Spring SseEmitter 구현 | SseEmitter, 연결 관리, heartbeat | 🔲 |
| 1-5-3 | Frontend EventSource | EventSource API, 재연결 처리 | 🔲 |

### 6. 이력 조회 + 알람
| # | 항목 | 학습 내용 | 상태 |
|---|---|---|---|
| 1-6-1 | 기간 필터 API | 날짜 파라미터, 페이징 기본 | 🔲 |
| 1-6-2 | 알람 룰 CRUD | alarm_rule 관리 API | 🔲 |
| 1-6-3 | 알람 감지 로직 | 임계치 체크, alarm_event 기록 | 🔲 |
| 1-6-4 | UI 알람 표시 | 알람 목록 + 상태 컴포넌트 | 🔲 |

---

## Phase 2 — Apache Druid 도입
> **Phase DoD**: Druid에 메트릭 적재 + Spring API에서 Druid SQL 조회 확인
> **새 요소 1개**: Apache Druid

### 7. Druid 기초
| # | 항목 | 학습 내용 | 상태 |
|---|---|---|---|
| 2-7-1 | Druid 개념 이해 | 시계열 DB, Segment/롤업/다운샘플링 | 🔲 |
| 2-7-2 | Druid docker-compose | 단일 노드, M4 Pro 메모리 설정 | 🔲 |
| 2-7-3 | Ingestion Spec 작성 | HTTP push, datasource 설정 | 🔲 |
| 2-7-4 | Druid SQL 질의 | Spring에서 Druid 연결 + 조회 | 🔲 |
| 2-7-5 | MariaDB → Druid 전환 | 메트릭 적재 전환, MariaDB는 메타만 유지 | 🔲 |

---

## Phase 3A — Kafka 도입 (실시간 스트리밍)
> **Phase DoD**: Agent → Kafka → Druid 파이프라인 end-to-end 확인
> **새 요소 1개**: Apache Kafka

### 8. Kafka
| # | 항목 | 학습 내용 | 상태 |
|---|---|---|---|
| 3A-8-1 | Kafka 개념 이해 | Topic/Partition/Consumer Group/Offset | 🔲 |
| 3A-8-2 | Kafka docker-compose | Zookeeper + Kafka 브로커 | 🔲 |
| 3A-8-3 | Python Producer 구현 | kafka-python, Agent → Kafka 발행 | 🔲 |
| 3A-8-4 | Druid Kafka Ingestion | Kafka Supervisor, 실시간 적재 | 🔲 |
| 3A-8-5 | Windows Agent 추가 | MSI 노트북, 동일 Kafka 연결 | 🔲 |

---

## Phase 3B — Airflow 도입 (배치/집계)
> **Phase DoD**: 시간 단위 집계 DAG 실행 + MariaDB 요약 테이블 적재 확인
> **새 요소 1개**: Apache Airflow

### 9. Airflow
| # | 항목 | 학습 내용 | 상태 |
|---|---|---|---|
| 3B-9-1 | Airflow 개념 이해 | DAG / Task / Operator / Schedule | 🔲 |
| 3B-9-2 | Airflow docker-compose | LocalExecutor, Webserver/Scheduler | 🔲 |
| 3B-9-3 | 배치 집계 DAG | PythonOperator, 시간/일 단위 집계 | 🔲 |
| 3B-9-4 | 리포트/아카이빙 DAG | 요약 테이블 → MariaDB 적재 | 🔲 |

---

## Phase 4 — LLM 연동
> **Phase DoD**: 자연어로 메트릭 요약 조회 + UI 컨트롤 명령 1개 실행 확인
> **새 요소 1개**: LLM API + WebSocket

### 10. LLM 1차 — 요약/설명
| # | 항목 | 학습 내용 | 상태 |
|---|---|---|---|
| 4-10-1 | LLM API 기초 | Claude API / GPT API, 프롬프트 기본 | 🔲 |
| 4-10-2 | 메트릭 요약 프롬프트 | 이상 구간, 원인 후보, 추세 요약 설계 | 🔲 |
| 4-10-3 | Spring LLM 연동 | LLM API 호출 서비스, 응답 파싱 | 🔲 |
| 4-10-4 | UI Chat 인터페이스 | 자연어 질의 → LLM 응답 표시 | 🔲 |

### 11. LLM 2차 — UI 컨트롤
| # | 항목 | 학습 내용 | 상태 |
|---|---|---|---|
| 4-11-1 | 명령 화이트리스트 설계 | 허용 명령 정의, 파라미터 검증 규칙 | 🔲 |
| 4-11-2 | 자연어 → 명령 파싱 | 프롬프트 엔지니어링, 구조화 출력 | 🔲 |
| 4-11-3 | WebSocket UI 컨트롤 | STOMP, 양방향 명령 실행 | 🔲 |
| 4-11-4 | 권한/안전장치 구현 | 명령 실행 전 검증, 로그 기록 | 🔲 |
| 4-11-5 | E2E 테스트 | "CPU 알람 임계치 80으로 바꿔줘" → 실제 반영 확인 | 🔲 |

---

## 진행 현황 요약

| Phase | 전체 항목 | 완료 | 진행중 | 미시작 |
|---|---|---|---|---|
| Phase 0 | 14 | 1 | 0 | 13 |
| Phase 1 | 7 | 0 | 0 | 7 |
| Phase 2 | 5 | 0 | 0 | 5 |
| Phase 3A | 5 | 0 | 0 | 5 |
| Phase 3B | 4 | 0 | 0 | 4 |
| Phase 4 | 9 | 0 | 0 | 9 |
| **합계** | **44** | **1** | **0** | **43** |
