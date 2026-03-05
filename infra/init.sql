-- infra/init.sql
-- Phase 0: meta & alarm tables only (schema_v0)

CREATE TABLE IF NOT EXISTS device (
                                      device_id   VARCHAR(64)  PRIMARY KEY,
    hostname    VARCHAR(128) NOT NULL,
    os          VARCHAR(64),
    arch        VARCHAR(32),
    description VARCHAR(255),
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE IF NOT EXISTS alarm_rule (
                                          rule_id     INT          PRIMARY KEY AUTO_INCREMENT,
                                          device_id   VARCHAR(64),
    metric      VARCHAR(64)  NOT NULL,
    condition   ENUM('gt','lt','gte','lte') NOT NULL,
    threshold   FLOAT        NOT NULL,
    duration_s  INT          DEFAULT 0,
    severity    ENUM('info','warn','critical') DEFAULT 'warn',
    enabled     TINYINT(1)   DEFAULT 1,
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE IF NOT EXISTS alarm_event (
                                           event_id     BIGINT       PRIMARY KEY AUTO_INCREMENT,
                                           rule_id      INT          NOT NULL,
                                           device_id    VARCHAR(64)  NOT NULL,
    triggered_at DATETIME     NOT NULL,
    value        FLOAT,
    resolved_at  DATETIME     DEFAULT NULL,
    note         TEXT,
    CONSTRAINT fk_alarm_event_rule
    FOREIGN KEY (rule_id) REFERENCES alarm_rule(rule_id)
    );