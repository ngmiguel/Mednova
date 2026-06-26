package com.mednova.patient.application.service;

import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.patient.application.security.PatientAccessGuard;
import com.mednova.patient.domain.model.MedicalRecord;
import com.mednova.patient.domain.port.MedicalRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MedicalRecordApplicationService {

    private final MedicalRecordRepository medicalRecordRepository;
    private final PatientApplicationService patientApplicationService;
    private final PatientAccessGuard accessGuard;

    @Transactional
    public MedicalRecord create(UUID patientId, MedicalRecord record) {
        accessGuard.checkCanWrite();
        patientApplicationService.getByIdInternal(patientId);

        MedicalRecord toSave = MedicalRecord.builder()
                .id(UUID.randomUUID())
                .patientId(patientId)
                .doctorId(record.getDoctorId() != null ? record.getDoctorId() : accessGuard.currentUserId())
                .diagnosis(record.getDiagnosis())
                .notes(record.getNotes())
                .visitDate(record.getVisitDate())
                .createdAt(Instant.now())
                .build();
        return medicalRecordRepository.save(toSave);
    }

    @Transactional(readOnly = true)
    public List<MedicalRecord> listByPatient(UUID patientId) {
        var patient = patientApplicationService.getById(patientId);
        accessGuard.checkCanRead(patient);
        return medicalRecordRepository.findByPatientId(patientId);
    }

    @Transactional(readOnly = true)
    public MedicalRecord getById(UUID patientId, UUID recordId) {
        patientApplicationService.getById(patientId);
        return medicalRecordRepository.findByIdAndPatientId(recordId, patientId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Dossier médical", recordId));
    }
}
