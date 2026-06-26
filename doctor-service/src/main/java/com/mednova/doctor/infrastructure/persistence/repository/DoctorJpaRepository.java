package com.mednova.doctor.infrastructure.persistence.repository;

import com.mednova.doctor.domain.model.Specialty;
import com.mednova.doctor.infrastructure.persistence.entity.DoctorEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface DoctorJpaRepository extends JpaRepository<DoctorEntity, UUID> {

    Page<DoctorEntity> findBySpecialty(Specialty specialty, Pageable pageable);

    boolean existsByLicenseNumber(String licenseNumber);

    boolean existsByEmail(String email);
}
