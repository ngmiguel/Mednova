-- Comptes démo liés aux utilisateurs auth-service (DemoUserSeeder)
INSERT INTO patients (id, user_id, first_name, last_name, email, phone, date_of_birth, blood_type, gender, created_at, updated_at)
VALUES (
    '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
    '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
    'Jean',
    'Dupont',
    'patient.test@mednova.ai',
    '+33601020304',
    '1990-05-15',
    'O_POSITIVE',
    'M',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;
