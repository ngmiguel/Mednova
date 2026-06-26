CREATE TABLE vital_readings (
    id                  UUID PRIMARY KEY,
    patient_id          UUID           NOT NULL,
    patient_user_id     UUID,
    heart_rate          INTEGER,
    systolic_bp         INTEGER,
    diastolic_bp        INTEGER,
    temperature         NUMERIC(4, 1),
    oxygen_saturation   INTEGER,
    anomaly_detected    BOOLEAN        NOT NULL DEFAULT FALSE,
    anomaly_details     TEXT,
    recorded_at         TIMESTAMP      NOT NULL,
    created_at          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vital_readings_patient_id ON vital_readings (patient_id);
CREATE INDEX idx_vital_readings_patient_user_id ON vital_readings (patient_user_id);
CREATE INDEX idx_vital_readings_recorded_at ON vital_readings (recorded_at DESC);
CREATE INDEX idx_vital_readings_anomaly ON vital_readings (anomaly_detected) WHERE anomaly_detected = TRUE;
