package com.mednova.patient.domain.port;

import com.mednova.patient.domain.model.MedicalRecord;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MedicalRecordRepository {

    MedicalRecord save(MedicalRecord record);

    Optional<MedicalRecord> findByIdAndPatientId(UUID id, UUID patientId);

    List<MedicalRecord> findByPatientId(UUID patientId);
}
