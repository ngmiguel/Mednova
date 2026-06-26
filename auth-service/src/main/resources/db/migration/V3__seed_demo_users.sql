-- Comptes démo MedNova (mot de passe : password123)
-- Hash BCrypt généré par Spring BCryptPasswordEncoder

INSERT INTO users (id, email, password_hash, first_name, last_name, enabled, two_factor_enabled, created_at, updated_at)
VALUES
    ('a0000001-0000-4000-8000-000000000001', 'admin@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Alice', 'Admin', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('a0000002-0000-4000-8000-000000000002', 'dr.smith@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'John', 'Smith', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('a0000003-0000-4000-8000-000000000003', 'nurse@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Emma', 'Wilson', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6', 'patient.test@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Jean', 'Dupont', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('a0000004-0000-4000-8000-000000000004', 'auditor@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Marc', 'Audit', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    two_factor_enabled = FALSE,
    totp_secret = NULL,
    enabled = TRUE,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_ADMIN' WHERE u.email = 'admin@mednova.ai'
ON CONFLICT DO NOTHING;
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_DOCTOR' WHERE u.email = 'dr.smith@mednova.ai'
ON CONFLICT DO NOTHING;
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_NURSE' WHERE u.email = 'nurse@mednova.ai'
ON CONFLICT DO NOTHING;
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_PATIENT' WHERE u.email = 'patient.test@mednova.ai'
ON CONFLICT DO NOTHING;
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_AUDITOR' WHERE u.email = 'auditor@mednova.ai'
ON CONFLICT DO NOTHING;
