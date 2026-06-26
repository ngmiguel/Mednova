package com.mednova.ai.infrastructure.persistence.repository;

import com.mednova.ai.infrastructure.persistence.entity.RiskAssessmentEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface RiskAssessmentJpaRepository extends JpaRepository<RiskAssessmentEntity, UUID> {

    Optional<RiskAssessmentEntity> findFirstByPatientIdOrderByAssessedAtDesc(UUID patientId);

    Page<RiskAssessmentEntity> findByPatientId(UUID patientId, Pageable pageable);

    Page<RiskAssessmentEntity> findByPatientUserId(UUID patientUserId, Pageable pageable);
}
