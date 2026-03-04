# schema_v0.md — 메트릭 스키마 정의
> **버전**: v0.1.0 | **최종 업데이트**: 2026-03-04
> **관리**: Claude 유지 | **상태**: 초안(Draft)

---

## 공통 규칙

| 항목 | 규칙 |
|---|---|
| 타임스탬프 | `ts` — UTC, millisecond epoch (Druid 기본) |
| 장비 식별 | `device_id` — hostname 또는 UUID (device 테이블 FK) |
| 수집 주기 | Core 5초, Process TopN 15초 (ADR-003) |
| Null 처리 | Optional 필드 미수집 시 NULL 허용 |

---

## [CORE] Druid 시계열 테이블

### metric_cpu
> CPU 코어별 사용률 및 주파수

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ts` | LONG | 수집 시각 (ms epoch) |
| `device_id` | STRING | 장비 식별자 |
| `core_id` | INT | 코어 번호 (-1 = 전체 평균) |
| `usage_pct` | FLOAT | 사용률 (0~100) |
| `freq_mhz` | FLOAT | 현재 주파수 (MHz) |
| `user_pct` | FLOAT | user 모드 사용률 |
| `system_pct` | FLOAT | system 모드 사용률 |
| `idle_pct` | FLOAT | idle 비율 |

---

### metric_memory
> 메모리 및 스왑 현황

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ts` | LONG | 수집 시각 |
| `device_id` | STRING | 장비 식별자 |
| `total_gb` | FLOAT | 전체 메모리 (GB) |
| `used_gb` | FLOAT | 사용 중 (GB) |
| `available_gb` | FLOAT | 사용 가능 (GB) |
| `used_pct` | FLOAT | 사용률 (0~100) |
| `swap_total_gb` | FLOAT | 스왑 전체 |
| `swap_used_gb` | FLOAT | 스왑 사용 중 |

---

### metric_disk
> 디스크 I/O 및 사용량 (마운트 포인트별)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ts` | LONG | 수집 시각 |
| `device_id` | STRING | 장비 식별자 |
| `mount` | STRING | 마운트 포인트 (예: /) |
| `read_mbps` | FLOAT | 읽기 속도 (MB/s) |
| `write_mbps` | FLOAT | 쓰기 속도 (MB/s) |
| `used_gb` | FLOAT | 사용 중 (GB) |
| `total_gb` | FLOAT | 전체 용량 (GB) |
| `used_pct` | FLOAT | 사용률 (0~100) |

---

### metric_network
> 네트워크 인터페이스별 트래픽

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ts` | LONG | 수집 시각 |
| `device_id` | STRING | 장비 식별자 |
| `iface` | STRING | 인터페이스명 (예: en0, lo0) |
| `rx_mbps` | FLOAT | 수신 속도 (MB/s) |
| `tx_mbps` | FLOAT | 송신 속도 (MB/s) |
| `rx_bytes_total` | LONG | 누적 수신 바이트 |
| `tx_bytes_total` | LONG | 누적 송신 바이트 |

---

### metric_battery
> 배터리 상태 (Mac 전용)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ts` | LONG | 수집 시각 |
| `device_id` | STRING | 장비 식별자 |
| `pct` | FLOAT | 배터리 잔량 (0~100) |
| `is_charging` | BOOLEAN | 충전 중 여부 |
| `power_source` | STRING | Battery / AC Power |
| `cycle_count` | INT | 충방전 사이클 수 |
| `time_remaining_min` | INT | 예상 잔여 시간 (분), -1=계산중 |

---

### metric_process
> 프로세스 TopN (ADR-004: CPU 기준 상위 10개)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ts` | LONG | 수집 시각 |
| `device_id` | STRING | 장비 식별자 |
| `pid` | INT | 프로세스 ID |
| `name` | STRING | 프로세스 이름 |
| `cpu_pct` | FLOAT | CPU 사용률 |
| `mem_mb` | FLOAT | 메모리 사용 (MB) |
| `mem_pct` | FLOAT | 메모리 사용률 |
| `status` | STRING | running/sleeping 등 |
| `user` | STRING | 실행 사용자 |

---

## [OPTIONAL] Druid 시계열 테이블 (Phase 2+)

### metric_thermal *(Optional)*
> CPU/GPU 온도 및 팬 속도 (macOS: powermetrics 또는 SMC)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ts` | LONG | 수집 시각 |
| `device_id` | STRING | 장비 식별자 |
| `sensor` | STRING | 센서명 (예: cpu_die, gpu) |
| `temp_c` | FLOAT | 온도 (℃) |
| `fan_rpm` | INT | 팬 RPM (없으면 NULL) |

---

### metric_gpu *(Optional)*
> GPU 사용률 (M4 Pro: powermetrics)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `ts` | LONG | 수집 시각 |
| `device_id` | STRING | 장비 식별자 |
| `gpu_id` | INT | GPU 번호 |
| `usage_pct` | FLOAT | GPU 사용률 |
| `mem_used_mb` | FLOAT | GPU 메모리 사용 |

---

## [MariaDB] 메타 / 알람 테이블

### device
```sql
CREATE TABLE device (
    device_id   VARCHAR(64)  PRIMARY KEY,
    hostname    VARCHAR(128) NOT NULL,
    os          VARCHAR(64),          -- macOS 15.x / Windows 11
    arch        VARCHAR(32),          -- arm64 / x86_64
    description VARCHAR(255),
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
);
```

### alarm_rule
```sql
CREATE TABLE alarm_rule (
    rule_id     INT          PRIMARY KEY AUTO_INCREMENT,
    device_id   VARCHAR(64),                          -- NULL = 전체 장비 적용
    metric      VARCHAR(64)  NOT NULL,                -- cpu.usage_pct
    condition   ENUM('gt','lt','gte','lte') NOT NULL, -- 비교 조건
    threshold   FLOAT        NOT NULL,                -- 임계값
    duration_s  INT          DEFAULT 0,               -- 지속 시간(초) 초과 시 발동
    severity    ENUM('info','warn','critical') DEFAULT 'warn',
    enabled     TINYINT(1)   DEFAULT 1,
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
);
```

### alarm_event
```sql
CREATE TABLE alarm_event (
    event_id    BIGINT       PRIMARY KEY AUTO_INCREMENT,
    rule_id     INT          NOT NULL,
    device_id   VARCHAR(64)  NOT NULL,
    triggered_at DATETIME    NOT NULL,
    value       FLOAT,                                -- 트리거 시점 값
    resolved_at DATETIME     DEFAULT NULL,            -- NULL = 미해소
    note        TEXT,
    FOREIGN KEY (rule_id) REFERENCES alarm_rule(rule_id)
);
```

---

## 수집 주기 정리

| 그룹 | 대상 | 주기 |
|---|---|---|
| Core Fast | cpu, memory, network, battery | 5초 |
| Core Slow | disk, process TopN | 15초 |
| Optional | thermal, gpu | 30초 |
