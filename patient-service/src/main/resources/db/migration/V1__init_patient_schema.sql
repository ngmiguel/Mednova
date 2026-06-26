CREATE TABLE patients (
    id                 UUID PRIMARY KEY,
    user_id            UUID,
    first_name         VARCHAR(100) NOT NULL,
    last_name          VARCHAR(100) NOT NULL,
    email              VARCHAR(255),
    phone              VARCHAR(30),
    date_of_birth      DATE         NOT NULL,
    blood_type         VARCHAR(5),
    gender             VARCHAR(20),
    address            VARCHAR(500),
    emergency_contact  VARCHAR(255),
    created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medical_records (
    id          UUID PRIMARY KEY,
    patient_id  UUID         NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    doctor_id   UUID,
    diagnosis   VARCHAR(500) NOT NULL,
    notes       TEXT,
    visit_date  DATE         NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE treatments (
    id            UUID PRIMARY KEY,
    patient_id    UUID         NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    medication    VARCHAR(255) NOT NULL,
    dosage        VARCHAR(100) NOT NULL,
    frequency     VARCHAR(100),
    start_date    DATE         NOT NULL,
    end_date      DATE,
    prescribed_by UUID,
    active        BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE allergies (
    id           UUID PRIMARY KEY,
    patient_id   UUID         NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    allergen     VARCHAR(255) NOT NULL,
    severity     VARCHAR(20)  NOT NULL,
    reaction     VARCHAR(500),
    diagnosed_at DATE,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_patients_user_id ON patients (user_id);
CREATE INDEX idx_patients_email ON patients (email);
CREATE INDEX idx_medical_records_patient_id ON medical_records (patient_id);
CREATE INDEX idx_treatments_patient_id ON treatments (patient_id);
CREATE INDEX idx_allergies_patient_id ON allergies (patient_id);
