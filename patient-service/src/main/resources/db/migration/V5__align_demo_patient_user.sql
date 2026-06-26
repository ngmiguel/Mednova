-- Lie le dossier patient démo à l'utilisateur auth canonique
UPDATE patients
SET user_id = '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
    email = 'patient.test@mednova.ai',
    first_name = 'Jean',
    last_name = 'Dupont',
    updated_at = CURRENT_TIMESTAMP
WHERE id = '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6';
