package com.mednova.patient.application.service;

import com.mednova.patient.application.security.PatientAccessGuard;
import com.mednova.patient.domain.model.Treatment;
import com.mednova.patient.domain.port.TreatmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TreatmentApplicationService {

    private final TreatmentRepository treatmentRepository;
    private final PatientApplicationService patientApplicationService;
    private final PatientAccessGuard accessGuard;

    @Transactional
    public Treatment create(UUID patientId, Treatment treatment) {
        accessGuard.checkCanWrite();
        patientApplicationService.getByIdInternal(patientId);

        Treatment toSave = Treatment.builder()
                .id(UUID.randomUUID())
                .patientId(patientId)
                .medication(treatment.getMedication())
                .dosage(treatment.getDosage())
                .frequency(treatment.getFrequency())
                .startDate(treatment.getStartDate())
                .endDate(treatment.getEndDate())
                .prescribedBy(treatment.getPrescribedBy() != null ? treatment.getPrescribedBy() : accessGuard.currentUserId())
                .active(treatment.isActive())
                .createdAt(Instant.now())
                .build();
        return treatmentRepository.save(toSave);
    }

    @Transactional(readOnly = true)
    public List<Treatment> listByPatient(UUID patientId) {
        var patient = patientApplicationService.getById(patientId);
        accessGuard.checkCanRead(patient);
        return treatmentRepository.findByPatientId(patientId);
    }
}
