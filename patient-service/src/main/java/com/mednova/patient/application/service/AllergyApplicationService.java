package com.mednova.patient.application.service;

import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.patient.application.security.PatientAccessGuard;
import com.mednova.patient.domain.model.Allergy;
import com.mednova.patient.domain.port.AllergyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AllergyApplicationService {

    private final AllergyRepository allergyRepository;
    private final PatientApplicationService patientApplicationService;
    private final PatientAccessGuard accessGuard;

    @Transactional
    public Allergy create(UUID patientId, Allergy allergy) {
        accessGuard.checkCanWrite();
        patientApplicationService.getByIdInternal(patientId);

        Allergy toSave = Allergy.builder()
                .id(UUID.randomUUID())
                .patientId(patientId)
                .allergen(allergy.getAllergen())
                .severity(allergy.getSeverity())
                .reaction(allergy.getReaction())
                .diagnosedAt(allergy.getDiagnosedAt())
                .createdAt(Instant.now())
                .build();
        return allergyRepository.save(toSave);
    }

    @Transactional(readOnly = true)
    public List<Allergy> listByPatient(UUID patientId) {
        var patient = patientApplicationService.getById(patientId);
        accessGuard.checkCanRead(patient);
        return allergyRepository.findByPatientId(patientId);
    }

    @Transactional
    public void delete(UUID patientId, UUID allergyId) {
        accessGuard.checkCanWrite();
        patientApplicationService.getByIdInternal(patientId);
        allergyRepository.findByIdAndPatientId(allergyId, patientId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Allergie", allergyId));
        allergyRepository.deleteById(allergyId);
    }
}
