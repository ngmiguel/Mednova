CREATE TABLE audit_events (
    id              UUID PRIMARY KEY,
    event_id        VARCHAR(64)  NOT NULL UNIQUE,
    event_type      VARCHAR(80)  NOT NULL,
    source          VARCHAR(80)  NOT NULL,
    correlation_id  VARCHAR(64),
    payload         TEXT         NOT NULL,
    received_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_events_event_type ON audit_events (event_type);
CREATE INDEX idx_audit_events_source ON audit_events (source);
CREATE INDEX idx_audit_events_received_at ON audit_events (received_at DESC);
CREATE INDEX idx_audit_events_correlation_id ON audit_events (correlation_id);
