# adr.md — Architecture Decision Records
> **관리**: Claude 유지 | 결정이 생길 때마다 추가
> **형식**: 날짜 / 제목 / 컨텍스트 / 결정 / 이유 / 결과

---

## ADR-001 · GitHub를 SSOT로, Claude=문서 / GPT=코드 역할 분리
**날짜**: 2026-03-04
**상태**: 확정

**컨텍스트**: Claude와 ChatGPT를 동시에 협업 파트너로 사용하되, 두 LLM 간 컨텍스트 공유 방법이 필요함.

**결정**: GitHub repo 1개를 SSOT로 사용. Claude는 `/docs` 문서 유지, GPT는 코드/구성 산출물 담당. 사용자가 merge 및 실행 결과 공유.

**이유**: 세션 간 컨텍스트 유지, LLM 간 역할 충돌 방지, 문서-코드 분리로 각 LLM이 잘하는 것에 집중.

**결과**: 매 세션 시작 시 `PROJECT_SNAPSHOT.md`를 첨부하면 컨텍스트 복원 가능.

---

## ADR-002 · Phase 0은 Kafka 없이 Agent → MariaDB 직접 적재로 시작
**날짜**: 2026-03-04
**상태**: 확정

**컨텍스트**: Kafka, Druid, Airflow를 처음부터 모두 도입하면 학습 부담이 크고 초기 환경 구성 실패 시 진도가 막힘.

**결정**: Phase 0~1은 Python Agent가 MariaDB에 직접 INSERT. Kafka는 Phase 3에서 도입.

**이유**: 가장 단순한 경로로 "그래프 보이는 것"을 먼저 달성. 복잡도를 단계적으로 올림.

**결과**: Phase 0 완료 기준은 "Mac Agent → MariaDB → 웹 UI 그래프 1개 보임".

---

## ADR-003 · 수집 주기: Core Fast 5초, Core Slow 15초
**날짜**: 2026-03-04
**상태**: 확정

**컨텍스트**: 수집 주기가 짧을수록 데이터 양이 많고 M4 Pro 리소스 소모가 커짐.

**결정**:
- Core Fast (cpu, memory, network, battery): **5초**
- Core Slow (disk I/O, process TopN): **15초**
- Optional (thermal, gpu): **30초**

**이유**: 5초면 실시간 감시에 충분. 디스크/프로세스는 변화가 느리고 수집 비용이 상대적으로 큼.

**결과**: 하루 데이터량 예상 — Fast 4종 × 86400/5 ≒ 69,120 rows/day/장비.

---

## ADR-004 · Process TopN 기준: CPU 사용률 상위 10개
**날짜**: 2026-03-04
**상태**: 확정

**컨텍스트**: 전체 프로세스를 수집하면 데이터 양이 과도함 (Mac 기준 수백 개).

**결정**: CPU 사용률 기준 상위 10개 프로세스만 수집.

**이유**: 이상 탐지와 리소스 감시 목적에는 TopN으로 충분. 전체 수집은 Optional로 분류.

**결과**: `metric_process` 테이블은 15초마다 10 rows 적재 = 57,600 rows/day/장비.

---

## ADR-005 · Windows MSI 노트북은 Phase 3 이후 2번째 에이전트로 추가
**날짜**: 2026-03-04
**상태**: 확정

**컨텍스트**: Windows 노트북을 처음부터 포함하면 OS별 수집 차이(SMC, psutil 호환성 등) 처리 복잡도 증가.

**결정**: Phase 0~2는 Mac 단일 에이전트로만 진행. Windows는 Phase 3 Kafka 도입 시점에 2번째 에이전트로 추가.

**이유**: 단일 환경에서 파이프라인을 먼저 안정화. multi-agent는 Kafka 토픽 분리로 자연스럽게 확장 가능.

**결과**: `device_id` 설계에 multi-device를 처음부터 반영해 둠 (schema_v0 공통 컬럼).
