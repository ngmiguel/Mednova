-- Conversation démo entre patient.test@mednova.ai et dr.smith@mednova.ai
INSERT INTO conversations (id, patient_user_id, doctor_user_id, patient_id, doctor_id, subject, created_at, updated_at)
VALUES (
    'd1000001-0000-4000-8000-000000000001',
    '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
    'a0000002-0000-4000-8000-000000000002',
    '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
    'a0000002-0000-4000-8000-000000000002',
    'Suivi hypertension',
    CURRENT_TIMESTAMP - INTERVAL '2 days',
    CURRENT_TIMESTAMP - INTERVAL '1 hour'
)
ON CONFLICT (patient_user_id, doctor_user_id) DO NOTHING;

INSERT INTO messages (id, conversation_id, sender_user_id, content, sent_at, read_at)
VALUES
    (
        'd2000001-0000-4000-8000-000000000001',
        'd1000001-0000-4000-8000-000000000001',
        '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
        'Bonjour docteur, j''ai des maux de tête depuis hier soir. Est-ce lié à mon traitement ?',
        CURRENT_TIMESTAMP - INTERVAL '2 days',
        CURRENT_TIMESTAMP - INTERVAL '1 day 23 hours'
    ),
    (
        'd2000002-0000-4000-8000-000000000002',
        'd1000001-0000-4000-8000-000000000001',
        'a0000002-0000-4000-8000-000000000002',
        'Bonjour Jean. Les céphalées peuvent être un effet secondaire léger. Surveillez votre tension et notez l''intensité.',
        CURRENT_TIMESTAMP - INTERVAL '1 day 20 hours',
        CURRENT_TIMESTAMP - INTERVAL '1 day 18 hours'
    ),
    (
        'd2000003-0000-4000-8000-000000000003',
        'd1000001-0000-4000-8000-000000000001',
        '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
        'Merci docteur. Ma tension ce matin était à 128/82. Dois-je prendre rendez-vous ?',
        CURRENT_TIMESTAMP - INTERVAL '1 hour',
        NULL
    )
ON CONFLICT (id) DO NOTHING;
