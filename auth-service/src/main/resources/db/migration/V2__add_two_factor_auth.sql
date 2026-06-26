ALTER TABLE users
    ADD COLUMN totp_secret VARCHAR(255),
    ADD COLUMN two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX idx_users_two_factor_enabled ON users (two_factor_enabled);
