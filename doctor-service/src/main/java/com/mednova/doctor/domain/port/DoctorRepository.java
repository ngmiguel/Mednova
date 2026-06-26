package com.mednova.doctor.domain.port;

import com.mednova.doctor.domain.model.Doctor;
import com.mednova.doctor.domain.model.Specialty;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;
import java.util.UUID;

public interface DoctorRepository {

    Doctor save(Doctor doctor);

    Optional<Doctor> findById(UUID id);

    Page<Doctor> findAll(Pageable pageable);

    Page<Doctor> findBySpecialty(Specialty specialty, Pageable pageable);

    void deleteById(UUID id);

    boolean existsById(UUID id);

    boolean existsByLicenseNumber(String licenseNumber);

    boolean existsByEmail(String email);
}
