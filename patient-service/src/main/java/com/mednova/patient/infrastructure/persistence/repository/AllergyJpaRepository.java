package com.mednova.patient.infrastructure.persistence.repository;

import com.mednova.patient.infrastructure.persistence.entity.AllergyEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AllergyJpaRepository extends JpaRepository<AllergyEntity, UUID> {

    List<AllergyEntity> findByPatientIdOrderByCreatedAtDesc(UUID patientId);

    Optional<AllergyEntity> findByIdAndPatientId(UUID id, UUID patientId);
}
