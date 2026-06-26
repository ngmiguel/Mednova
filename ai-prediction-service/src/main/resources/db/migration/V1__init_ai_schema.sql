CREATE TABLE risk_assessments (
    id                  UUID PRIMARY KEY,
    patient_id          UUID         NOT NULL,
    patient_user_id     UUID,
    reading_id          UUID,
    risk_score          INTEGER      NOT NULL,
    risk_level          VARCHAR(20)  NOT NULL,
    factors             TEXT         NOT NULL,
    recommendation      TEXT,
    trigger_event_type  VARCHAR(80),
    correlation_id      VARCHAR(64),
    assessed_at         TIMESTAMP    NOT NULL,
    created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_risk_score CHECK (risk_score >= 0 AND risk_score <= 100),
    CONSTRAINT chk_risk_level CHECK (risk_level IN ('LOW', 'MODERATE', 'HIGH', 'CRITICAL'))
);

CREATE INDEX idx_risk_assessments_patient_id ON risk_assessments (patient_id);
CREATE INDEX idx_risk_assessments_patient_user_id ON risk_assessments (patient_user_id);
CREATE INDEX idx_risk_assessments_risk_level ON risk_assessments (risk_level);
CREATE INDEX idx_risk_assessments_assessed_at ON risk_assessments (assessed_at DESC);
