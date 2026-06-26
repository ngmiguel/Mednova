package com.mednova.patient.domain.port;

import com.mednova.patient.domain.model.Patient;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;
import java.util.UUID;

public interface PatientRepository {

    Patient save(Patient patient);

    Optional<Patient> findById(UUID id);

    Optional<Patient> findByUserId(UUID userId);

    Page<Patient> findAll(Pageable pageable);

    void deleteById(UUID id);

    boolean existsById(UUID id);
}
