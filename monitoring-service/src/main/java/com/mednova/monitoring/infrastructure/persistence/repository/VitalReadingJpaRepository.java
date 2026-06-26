package com.mednova.monitoring.infrastructure.persistence.repository;

import com.mednova.monitoring.infrastructure.persistence.entity.VitalReadingEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface VitalReadingJpaRepository extends JpaRepository<VitalReadingEntity, UUID> {

    Optional<VitalReadingEntity> findFirstByPatientIdOrderByRecordedAtDesc(UUID patientId);

    Page<VitalReadingEntity> findByPatientId(UUID patientId, Pageable pageable);

    Page<VitalReadingEntity> findByPatientUserId(UUID patientUserId, Pageable pageable);

    Page<VitalReadingEntity> findByAnomalyDetected(boolean anomalyDetected, Pageable pageable);

    boolean existsByPatientIdAndPatientUserId(UUID patientId, UUID patientUserId);
}
