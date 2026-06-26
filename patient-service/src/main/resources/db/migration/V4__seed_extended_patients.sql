-- Patients démo étendus

INSERT INTO patients (id, user_id, first_name, last_name, email, phone, date_of_birth, blood_type, gender, address, emergency_contact, created_at, updated_at)
VALUES
    ('b1000001-0000-4000-8000-000000000001', 'b1000001-0000-4000-8000-000000000001',
     'Marie', 'Curie', 'marie.curie@mednova.ai', '+33611223344', '1985-03-12', 'A_POSITIVE', 'F',
     '12 rue Pasteur, Paris', 'Paul Curie +33699887766', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b1000002-0000-4000-8000-000000000002', 'b1000002-0000-4000-8000-000000000002',
     'Pierre', 'Martin', 'pierre.martin@mednova.ai', '+33622334455', '1978-07-22', 'B_POSITIVE', 'M',
     '8 avenue Victor Hugo, Lyon', 'Anne Martin +33688776655', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b1000003-0000-4000-8000-000000000003', 'b1000003-0000-4000-8000-000000000003',
     'Sophie', 'Bernard', 'sophie.bernard@mednova.ai', '+33633445566', '1992-11-05', 'AB_POSITIVE', 'F',
     '25 boulevard Haussmann, Paris', 'Marc Bernard +33677665544', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('b1000004-0000-4000-8000-000000000004', 'b1000004-0000-4000-8000-000000000004',
     'Ahmed', 'Benali', 'ahmed.benali@mednova.ai', '+33644556677', '1988-01-18', 'O_NEGATIVE', 'M',
     '3 rue de la République, Marseille', 'Sara Benali +33666554433', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

INSERT INTO allergies (id, patient_id, allergen, severity, created_at)
VALUES
    ('c1000001-0000-4000-8000-000000000001', '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6', 'Pénicilline', 'HIGH', CURRENT_TIMESTAMP),
    ('c1000002-0000-4000-8000-000000000002', 'b1000001-0000-4000-8000-000000000001', 'Arachides', 'CRITICAL', CURRENT_TIMESTAMP),
    ('c1000003-0000-4000-8000-000000000003', 'b1000003-0000-4000-8000-000000000003', 'Latex', 'MODERATE', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

INSERT INTO medical_records (id, patient_id, diagnosis, visit_date, created_at)
VALUES
    ('d1000001-0000-4000-8000-000000000001', '70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6', 'Hypertension légère — suivi trimestriel', '2026-03-10', CURRENT_TIMESTAMP),
    ('d1000002-0000-4000-8000-000000000002', 'b1000001-0000-4000-8000-000000000001', 'Asthme allergique contrôlé', '2026-04-02', CURRENT_TIMESTAMP),
    ('d1000003-0000-4000-8000-000000000003', 'b1000002-0000-4000-8000-000000000002', 'Diabète type 2 — bilan HbA1c', '2026-05-15', CURRENT_TIMESTAMP),
    ('d1000004-0000-4000-8000-000000000004', 'b1000004-0000-4000-8000-000000000004', 'Migraines chroniques', '2026-02-20', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;
