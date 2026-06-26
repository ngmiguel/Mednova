CREATE TABLE notifications (
    id                  UUID PRIMARY KEY,
    patient_id          UUID,
    type                VARCHAR(40)  NOT NULL,
    channel             VARCHAR(20)  NOT NULL,
    title               VARCHAR(255) NOT NULL,
    message             TEXT         NOT NULL,
    status              VARCHAR(20)  NOT NULL DEFAULT 'UNREAD',
    target_role         VARCHAR(30),
    source_event_type   VARCHAR(80),
    correlation_id      VARCHAR(64),
    created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at             TIMESTAMP,
    CONSTRAINT chk_notification_status CHECK (status IN ('UNREAD', 'READ')),
    CONSTRAINT chk_notification_channel CHECK (channel IN ('IN_APP', 'EMAIL'))
);

CREATE INDEX idx_notifications_patient_id ON notifications (patient_id);
CREATE INDEX idx_notifications_status ON notifications (status);
CREATE INDEX idx_notifications_type ON notifications (type);
CREATE INDEX idx_notifications_created_at ON notifications (created_at DESC);
CREATE INDEX idx_notifications_target_role ON notifications (target_role);
