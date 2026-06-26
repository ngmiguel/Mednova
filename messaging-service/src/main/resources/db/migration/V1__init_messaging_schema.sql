CREATE TABLE conversations (
    id                UUID PRIMARY KEY,
    patient_user_id   UUID         NOT NULL,
    doctor_user_id    UUID         NOT NULL,
    patient_id        UUID,
    doctor_id         UUID,
    subject           VARCHAR(255),
    created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_conversations_patient_doctor UNIQUE (patient_user_id, doctor_user_id)
);

CREATE TABLE messages (
    id                UUID PRIMARY KEY,
    conversation_id   UUID         NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
    sender_user_id    UUID         NOT NULL,
    content           TEXT         NOT NULL,
    sent_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at           TIMESTAMP
);

CREATE INDEX idx_conversations_patient_user_id ON conversations (patient_user_id);
CREATE INDEX idx_conversations_doctor_user_id ON conversations (doctor_user_id);
CREATE INDEX idx_conversations_updated_at ON conversations (updated_at DESC);
CREATE INDEX idx_messages_conversation_id ON messages (conversation_id);
CREATE INDEX idx_messages_sent_at ON messages (sent_at);
