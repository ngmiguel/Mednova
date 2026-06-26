CREATE TABLE doctors (
    id              UUID PRIMARY KEY,
    user_id         UUID UNIQUE,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    phone           VARCHAR(30),
    specialty       VARCHAR(50)  NOT NULL,
    license_number  VARCHAR(50)  NOT NULL UNIQUE,
    bio             TEXT,
    active          BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE availabilities (
    id          UUID PRIMARY KEY,
    doctor_id   UUID        NOT NULL REFERENCES doctors (id) ON DELETE CASCADE,
    day_of_week VARCHAR(10) NOT NULL,
    start_time  TIME        NOT NULL,
    end_time    TIME        NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_availability_time CHECK (end_time > start_time)
);

CREATE INDEX idx_doctors_specialty ON doctors (specialty);
CREATE INDEX idx_doctors_user_id ON doctors (user_id);
CREATE INDEX idx_availabilities_doctor_id ON availabilities (doctor_id);
