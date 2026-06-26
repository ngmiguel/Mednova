package com.mednova.patient.infrastructure.persistence.repository;

import com.mednova.patient.infrastructure.persistence.entity.TreatmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TreatmentJpaRepository extends JpaRepository<TreatmentEntity, UUID> {

    List<TreatmentEntity> findByPatientIdOrderByStartDateDesc(UUID patientId);
}
