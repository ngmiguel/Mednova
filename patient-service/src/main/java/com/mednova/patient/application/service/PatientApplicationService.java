package com.mednova.patient.application.service;

import com.mednova.common.dto.PageResponse;
import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.patient.application.security.PatientAccessGuard;
import com.mednova.patient.domain.model.Patient;
import com.mednova.patient.domain.port.PatientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PatientApplicationService {

    private final PatientRepository patientRepository;
    private final PatientAccessGuard accessGuard;
    private final com.mednova.patient.infrastructure.kafka.PatientEventPublisher patientEventPublisher;

    @Transactional
    public Patient create(Patient patient) {
        accessGuard.checkCanWrite();
        Patient toSave = Patient.builder()
                .id(patient.getId() != null ? patient.getId() : UUID.randomUUID())
                .userId(patient.getUserId())
                .firstName(patient.getFirstName())
                .lastName(patient.getLastName())
                .email(patient.getEmail())
                .phone(patient.getPhone())
                .dateOfBirth(patient.getDateOfBirth())
                .bloodType(patient.getBloodType())
                .gender(patient.getGender())
                .address(patient.getAddress())
                .emergencyContact(patient.getEmergencyContact())
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        Patient saved = patientRepository.save(toSave);
        patientEventPublisher.publishCreated(saved, null);
        return saved;
    }

    @Transactional(readOnly = true)
    public Patient getById(UUID id) {
        Patient patient = patientRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Patient", id));
        accessGuard.checkCanRead(patient);
        return patient;
    }

    @Transactional(readOnly = true)
    public PageResponse<Patient> list(Pageable pageable) {
        accessGuard.checkCanList();
        var page = patientRepository.findAll(pageable);
        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional
    public Patient update(UUID id, Patient updates) {
        accessGuard.checkCanWrite();
        Patient existing = patientRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Patient", id));

        Patient updated = Patient.builder()
                .id(existing.getId())
                .userId(updates.getUserId() != null ? updates.getUserId() : existing.getUserId())
                .firstName(updates.getFirstName())
                .lastName(updates.getLastName())
                .email(updates.getEmail())
                .phone(updates.getPhone())
                .dateOfBirth(updates.getDateOfBirth())
                .bloodType(updates.getBloodType())
                .gender(updates.getGender())
                .address(updates.getAddress())
                .emergencyContact(updates.getEmergencyContact())
                .createdAt(existing.getCreatedAt())
                .updatedAt(Instant.now())
                .build();
        return patientRepository.save(updated);
    }

    @Transactional
    public void delete(UUID id) {
        accessGuard.checkCanDelete();
        if (!patientRepository.existsById(id)) {
            throw ResourceNotFoundException.forResource("Patient", id);
        }
        patientRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public Patient getByIdInternal(UUID id) {
        return patientRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Patient", id));
    }
}
