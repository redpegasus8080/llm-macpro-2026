-- =============================================================
-- infra/init.sql
-- Phase 0: 메타 & 알람 테이블 초기화 (schema_v0 기준)
-- 관리: Claude | 최종 업데이트: 2026-03-04
-- =============================================================

-- -------------------------------------------------------------
-- 1. device
--    수집 에이전트가 설치된 장비 정보를 관리하는 테이블
--    Phase 3A에서 Windows 노트북 추가 시 row 1개 추가로 확장 가능
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS device (
    device_id   VARCHAR(64)  NOT NULL  COMMENT '장비 고유 ID (hostname 또는 UUID)',
    hostname    VARCHAR(128) NOT NULL  COMMENT '장비 호스트명 (예: pegasus-macbook)',
    os          VARCHAR(64)            COMMENT '운영체제 (예: macOS 15.x / Windows 11)',
    arch        VARCHAR(32)            COMMENT 'CPU 아키텍처 (예: arm64 / x86_64)',
    description VARCHAR(255)           COMMENT '장비 설명 (자유 입력)',
    created_at  DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP COMMENT '등록 일시',
    PRIMARY KEY (device_id)
) COMMENT = '수집 에이전트가 설치된 장비 등록 테이블';

-- -------------------------------------------------------------
-- 2. alarm_rule
--    알람 임계치 룰을 정의하는 테이블
--    device_id가 NULL이면 전체 장비에 적용되는 공통 룰
--    예) cpu.usage_pct > 80 이 30초 이상 지속되면 critical 알람
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS alarm_rule (
    rule_id     INT          NOT NULL  AUTO_INCREMENT  COMMENT '알람 룰 고유 ID',
    device_id   VARCHAR(64)            COMMENT '적용 장비 ID (NULL = 전체 장비 공통 적용)',
    metric      VARCHAR(64)  NOT NULL  COMMENT '모니터링 메트릭 (예: cpu.usage_pct, memory.used_pct)',
    condition_type ENUM('gt','lt','gte','lte') NOT NULL COMMENT '비교 조건 (gt=초과, lt=미만, gte=이상, lte=이하)',
    threshold   FLOAT        NOT NULL  COMMENT '임계값 (예: 80.0)',
    duration_s  INT          NOT NULL  DEFAULT 0  COMMENT '지속 시간(초) - 이 시간 이상 조건 충족 시 발동 (0=즉시)',
    severity    ENUM('info','warn','critical') NOT NULL DEFAULT 'warn' COMMENT '알람 심각도',
    enabled     TINYINT(1)   NOT NULL  DEFAULT 1  COMMENT '룰 활성화 여부 (1=활성, 0=비활성)',
    created_at  DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP COMMENT '룰 생성 일시',
    PRIMARY KEY (rule_id)
) COMMENT = '알람 임계치 룰 정의 테이블';

-- -------------------------------------------------------------
-- 3. alarm_event
--    알람이 실제로 발생/해소된 이력을 기록하는 테이블
--    resolved_at이 NULL이면 아직 해소되지 않은 활성 알람
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS alarm_event (
    event_id     BIGINT       NOT NULL  AUTO_INCREMENT  COMMENT '알람 이벤트 고유 ID',
    rule_id      INT          NOT NULL  COMMENT '발동된 알람 룰 ID (alarm_rule 참조)',
    device_id    VARCHAR(64)  NOT NULL  COMMENT '알람이 발생한 장비 ID',
    triggered_at DATETIME     NOT NULL  COMMENT '알람 발생 일시',
    value        FLOAT                  COMMENT '알람 발생 시점의 실제 측정값',
    resolved_at  DATETIME               DEFAULT NULL COMMENT '알람 해소 일시 (NULL = 아직 활성 상태)',
    note         TEXT                   COMMENT '비고 (수동 메모 또는 자동 분석 결과)',
    PRIMARY KEY (event_id)
) COMMENT = '알람 발생 및 해소 이력 테이블';

-- -------------------------------------------------------------
-- 권한 부여 (보안 습관: 항상 명시적으로 GRANT)
-- llm 유저에게 llm_macpro DB 전체 권한 부여
-- -------------------------------------------------------------
GRANT ALL PRIVILEGES ON llm_macpro.* TO 'llm'@'%';
FLUSH PRIVILEGES;