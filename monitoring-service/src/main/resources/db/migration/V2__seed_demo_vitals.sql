-- Constantes vitales démo

INSERT INTO vital_readings (id, patient_id, patient_user_id, heart_rate, systolic_bp, diastolic_bp, temperature, oxygen_saturation, anomaly_detected, anomaly_details, recorded_at, created_at)
VALUES
    ('g1000001-0000-4000-8000-000000000001', '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6', '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
     72, 128, 82, 36.7, 98, FALSE, NULL, '2026-06-24 08:00:00', CURRENT_TIMESTAMP),
    ('g1000002-0000-4000-8000-000000000002', 'b1000001-0000-4000-8000-000000000001', 'b1000001-0000-4000-8000-000000000001',
     88, 118, 76, 37.1, 97, FALSE, NULL, '2026-06-24 09:15:00', CURRENT_TIMESTAMP),
    ('g1000003-0000-4000-8000-000000000003', 'b1000002-0000-4000-8000-000000000002', 'b1000002-0000-4000-8000-000000000002',
     76, 135, 88, 36.5, 96, TRUE, 'Hypertension systolique légère', '2026-06-24 10:30:00', CURRENT_TIMESTAMP),
    ('g1000004-0000-4000-8000-000000000004', 'b1000004-0000-4000-8000-000000000004', 'b1000004-0000-4000-8000-000000000004',
     145, 190, 120, 39.5, 88, TRUE, 'Tachycardie + hypertension sévère + fièvre + SpO2 basse', '2026-06-23 22:00:00', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;
