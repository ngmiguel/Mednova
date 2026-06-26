-- Garantit les rôles infirmier pour tous les comptes démo nurse

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
JOIN roles r ON r.name = 'ROLE_NURSE'
WHERE u.email IN ('nurse@mednova.ai', 'nurse.martin@mednova.ai', 'nurse.durand@mednova.ai')
ON CONFLICT DO NOTHING;

UPDATE users SET enabled = TRUE, two_factor_enabled = FALSE, updated_at = CURRENT_TIMESTAMP
WHERE email IN ('nurse@mednova.ai', 'nurse.martin@mednova.ai', 'nurse.durand@mednova.ai');
