INSERT INTO risk_assessments (id, patient_id, patient_user_id, reading_id, risk_score, risk_level, factors, recommendation, trigger_event_type, assessed_at, created_at)
VALUES
    ('c1000001-0000-4000-8000-000000000001', '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6', '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
     NULL, 42, 'MODERATE', 'Tension élevée, antécédents familiaux', 'Surveillance tension 2x/jour, consultation sous 7 jours', 'VITALS_RECORDED',
     CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),
    ('c1000002-0000-4000-8000-000000000002', '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6', '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6',
     NULL, 68, 'HIGH', 'SpO2 basse, fréquence cardiaque élevée', 'Alerte staff — examen clinique urgent', 'VITALS_ANOMALY_DETECTED',
     CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '6 hours'),
    ('c1000003-0000-4000-8000-000000000003', 'b1000001-0000-4000-8000-000000000001', 'b1000001-0000-4000-8000-000000000001',
     NULL, 25, 'LOW', 'Paramètres stables', 'Poursuivre le suivi habituel', 'VITALS_RECORDED',
     CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;
