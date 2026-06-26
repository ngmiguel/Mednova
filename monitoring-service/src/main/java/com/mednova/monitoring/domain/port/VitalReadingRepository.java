package com.mednova.monitoring.domain.port;

import com.mednova.monitoring.domain.model.VitalReading;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;
import java.util.UUID;

public interface VitalReadingRepository {

    VitalReading save(VitalReading reading);

    Optional<VitalReading> findById(UUID id);

    Optional<VitalReading> findLatestByPatientId(UUID patientId);

    Page<VitalReading> findByPatientId(UUID patientId, Pageable pageable);

    Page<VitalReading> findByPatientUserId(UUID patientUserId, Pageable pageable);

    Page<VitalReading> findAll(Pageable pageable);

    Page<VitalReading> findByAnomalyDetected(boolean anomalyDetected, Pageable pageable);

    boolean existsByPatientIdAndPatientUserId(UUID patientId, UUID patientUserId);
}
