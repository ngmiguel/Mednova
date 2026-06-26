-- Utilisateurs démo étendus (mot de passe : password123)
-- Hash BCrypt identique aux comptes V3

INSERT INTO users (id, email, password_hash, first_name, last_name, enabled, two_factor_enabled, created_at, updated_at)
VALUES
    ('b1000001-0000-4000-8000-000000000001', 'marie.curie@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Marie', 'Curie', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b1000002-0000-4000-8000-000000000002', 'pierre.martin@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Pierre', 'Martin', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b1000003-0000-4000-8000-000000000003', 'sophie.bernard@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Sophie', 'Bernard', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b1000004-0000-4000-8000-000000000004', 'ahmed.benali@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Ahmed', 'Benali', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b2000001-0000-4000-8000-000000000001', 'dr.dubois@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Claire', 'Dubois', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b2000002-0000-4000-8000-000000000002', 'dr.laurent@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Michel', 'Laurent', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b2000003-0000-4000-8000-000000000003', 'dr.alami@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Fatima', 'Alami', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b3000001-0000-4000-8000-000000000001', 'nurse.martin@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Julie', 'Martin', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b3000002-0000-4000-8000-000000000002', 'nurse.durand@mednova.ai',
     '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa', 'Lucas', 'Durand', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    two_factor_enabled = FALSE,
    enabled = TRUE,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_PATIENT' WHERE u.email IN (
    'marie.curie@mednova.ai', 'pierre.martin@mednova.ai', 'sophie.bernard@mednova.ai', 'ahmed.benali@mednova.ai')
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_DOCTOR' WHERE u.email IN (
    'dr.dubois@mednova.ai', 'dr.laurent@mednova.ai', 'dr.alami@mednova.ai')
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_NURSE' WHERE u.email IN ('nurse@mednova.ai', 'nurse.martin@mednova.ai', 'nurse.durand@mednova.ai')
ON CONFLICT DO NOTHING;
