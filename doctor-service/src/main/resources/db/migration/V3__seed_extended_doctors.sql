-- Médecins démo étendus

INSERT INTO doctors (id, user_id, first_name, last_name, email, phone, specialty, license_number, bio, active, created_at, updated_at)
VALUES
    ('b2000001-0000-4000-8000-000000000001', 'b2000001-0000-4000-8000-000000000001',
     'Claire', 'Dubois', 'dr.dubois@mednova.ai', '+33145678901', 'CARDIOLOGY', 'MD-FR-002345',
     'Cardiologue — spécialiste rythme cardiaque et prévention', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b2000002-0000-4000-8000-000000000002', 'b2000002-0000-4000-8000-000000000002',
     'Michel', 'Laurent', 'dr.laurent@mednova.ai', '+33156789012', 'PEDIATRICS', 'MD-FR-003456',
     'Pédiatre — suivi nourrissons et vaccinations', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b2000003-0000-4000-8000-000000000003', 'b2000003-0000-4000-8000-000000000003',
     'Fatima', 'Alami', 'dr.alami@mednova.ai', '+33167890123', 'NEUROLOGY', 'MD-FR-004567',
     'Neurologue — épilepsie et troubles du sommeil', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (email) DO NOTHING;

INSERT INTO availabilities (id, doctor_id, day_of_week, start_time, end_time, created_at)
SELECT 'e1000001-0000-4000-8000-000000000001', d.id, 'MONDAY', '09:00', '17:00', CURRENT_TIMESTAMP
FROM doctors d WHERE d.email = 'dr.smith@mednova.ai'
ON CONFLICT (id) DO NOTHING;

INSERT INTO availabilities (id, doctor_id, day_of_week, start_time, end_time, created_at)
SELECT 'e1000002-0000-4000-8000-000000000002', d.id, 'WEDNESDAY', '09:00', '13:00', CURRENT_TIMESTAMP
FROM doctors d WHERE d.email = 'dr.smith@mednova.ai'
ON CONFLICT (id) DO NOTHING;

INSERT INTO availabilities (id, doctor_id, day_of_week, start_time, end_time, created_at)
SELECT 'e1000003-0000-4000-8000-000000000003', d.id, 'TUESDAY', '08:30', '18:00', CURRENT_TIMESTAMP
FROM doctors d WHERE d.email = 'dr.dubois@mednova.ai'
ON CONFLICT (id) DO NOTHING;

INSERT INTO availabilities (id, doctor_id, day_of_week, start_time, end_time, created_at)
SELECT 'e1000004-0000-4000-8000-000000000004', d.id, 'THURSDAY', '10:00', '16:00', CURRENT_TIMESTAMP
FROM doctors d WHERE d.email = 'dr.laurent@mednova.ai'
ON CONFLICT (id) DO NOTHING;

INSERT INTO availabilities (id, doctor_id, day_of_week, start_time, end_time, created_at)
SELECT 'e1000005-0000-4000-8000-000000000005', d.id, 'FRIDAY', '09:00', '12:00', CURRENT_TIMESTAMP
FROM doctors d WHERE d.email = 'dr.alami@mednova.ai'
ON CONFLICT (id) DO NOTHING;
