-- Réaligne le compte patient démo sur l'UUID canonique (évite les conflits après inscription manuelle)

DELETE FROM refresh_tokens
WHERE user_id IN (SELECT id FROM users WHERE email = 'patient.test@mednova.ai');

DELETE FROM user_roles
WHERE user_id IN (SELECT id FROM users WHERE email = 'patient.test@mednova.ai');

DELETE FROM users WHERE email = 'patient.test@mednova.ai';

INSERT INTO users (id, email, password_hash, first_name, last_name, enabled, two_factor_enabled, created_at, updated_at)
VALUES (
    '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
    'patient.test@mednova.ai',
    '$2a$10$KOgDYMeJ9JBaA3VNTw7DlONo.5ZVzHA3SG2qNyFCKztQKuJa807qa',
    'Jean', 'Dupont', TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.name = 'ROLE_PATIENT'
WHERE u.email = 'patient.test@mednova.ai'
ON CONFLICT DO NOTHING;
