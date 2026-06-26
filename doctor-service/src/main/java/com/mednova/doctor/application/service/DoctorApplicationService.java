package com.mednova.doctor.application.service;

import com.mednova.common.dto.PageResponse;
import com.mednova.common.exception.ConflictException;
import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.doctor.application.security.DoctorAccessGuard;
import com.mednova.doctor.domain.model.Doctor;
import com.mednova.doctor.domain.model.Specialty;
import com.mednova.doctor.domain.port.DoctorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DoctorApplicationService {

    private final DoctorRepository doctorRepository;
    private final DoctorAccessGuard accessGuard;

    @Transactional
    public Doctor create(Doctor doctor) {
        accessGuard.checkCanCreate();

        if (doctorRepository.existsByEmail(doctor.getEmail())) {
            throw new ConflictException("Un médecin existe déjà avec cet email");
        }
        if (doctorRepository.existsByLicenseNumber(doctor.getLicenseNumber())) {
            throw new ConflictException("Ce numéro de licence est déjà utilisé");
        }

        Doctor toSave = Doctor.builder()
                .id(UUID.randomUUID())
                .userId(doctor.getUserId())
                .firstName(doctor.getFirstName())
                .lastName(doctor.getLastName())
                .email(doctor.getEmail().toLowerCase())
                .phone(doctor.getPhone())
                .specialty(doctor.getSpecialty())
                .licenseNumber(doctor.getLicenseNumber())
                .bio(doctor.getBio())
                .active(true)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        return doctorRepository.save(toSave);
    }

    @Transactional(readOnly = true)
    public Doctor getById(UUID id) {
        accessGuard.checkCanRead();
        return doctorRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Médecin", id));
    }

    @Transactional(readOnly = true)
    public PageResponse<Doctor> list(Specialty specialty, Pageable pageable) {
        accessGuard.checkCanRead();
        var page = specialty != null
                ? doctorRepository.findBySpecialty(specialty, pageable)
                : doctorRepository.findAll(pageable);
        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional
    public Doctor update(UUID id, Doctor updates) {
        Doctor existing = doctorRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Médecin", id));
        accessGuard.checkCanUpdate(existing);

        Doctor updated = Doctor.builder()
                .id(existing.getId())
                .userId(updates.getUserId() != null ? updates.getUserId() : existing.getUserId())
                .firstName(updates.getFirstName())
                .lastName(updates.getLastName())
                .email(updates.getEmail().toLowerCase())
                .phone(updates.getPhone())
                .specialty(updates.getSpecialty())
                .licenseNumber(updates.getLicenseNumber())
                .bio(updates.getBio())
                .active(updates.isActive())
                .createdAt(existing.getCreatedAt())
                .updatedAt(Instant.now())
                .build();
        return doctorRepository.save(updated);
    }

    @Transactional
    public void delete(UUID id) {
        accessGuard.checkCanDelete();
        if (!doctorRepository.existsById(id)) {
            throw ResourceNotFoundException.forResource("Médecin", id);
        }
        doctorRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public Doctor getByIdInternal(UUID id) {
        return doctorRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Médecin", id));
    }
}
