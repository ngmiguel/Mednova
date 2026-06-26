CREATE TABLE appointments (
    id                UUID PRIMARY KEY,
    patient_id        UUID         NOT NULL,
    doctor_id         UUID         NOT NULL,
    patient_user_id   UUID         NOT NULL,
    doctor_user_id    UUID         NOT NULL,
    scheduled_at      TIMESTAMP    NOT NULL,
    duration_minutes  INTEGER      NOT NULL DEFAULT 30,
    reason            VARCHAR(255) NOT NULL,
    notes             TEXT,
    status            VARCHAR(20)  NOT NULL DEFAULT 'SCHEDULED',
    created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_appointment_duration CHECK (duration_minutes > 0 AND duration_minutes <= 480),
    CONSTRAINT chk_appointment_status CHECK (status IN ('SCHEDULED', 'CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW'))
);

CREATE INDEX idx_appointments_patient_id ON appointments (patient_id);
CREATE INDEX idx_appointments_doctor_id ON appointments (doctor_id);
CREATE INDEX idx_appointments_patient_user_id ON appointments (patient_user_id);
CREATE INDEX idx_appointments_doctor_user_id ON appointments (doctor_user_id);
CREATE INDEX idx_appointments_scheduled_at ON appointments (scheduled_at);
CREATE INDEX idx_appointments_status ON appointments (status);
