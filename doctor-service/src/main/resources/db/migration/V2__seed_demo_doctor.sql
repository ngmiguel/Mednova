-- Profil médecin démo lié à dr.smith@mednova.ai (user a0000002-...)
INSERT INTO doctors (id, user_id, first_name, last_name, email, phone, specialty, license_number, bio, active, created_at, updated_at)
VALUES (
    'a0000002-0000-4000-8000-000000000002',
    'a0000002-0000-4000-8000-000000000002',
    'John',
    'Smith',
    'dr.smith@mednova.ai',
    '+33123456789',
    'GENERAL_PRACTICE',
    'MD-FR-001234',
    'Médecin généraliste — démo MedNova',
    TRUE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (email) DO NOTHING;
