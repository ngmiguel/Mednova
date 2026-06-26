package com.mednova.monitoring.infrastructure.persistence.adapter;

import com.mednova.monitoring.domain.model.VitalReading;
import com.mednova.monitoring.domain.port.VitalReadingRepository;
import com.mednova.monitoring.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.monitoring.infrastructure.persistence.repository.VitalReadingJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class VitalReadingRepositoryAdapter implements VitalReadingRepository {

    private final VitalReadingJpaRepository vitalReadingJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public VitalReading save(VitalReading reading) {
        return persistenceMapper.toDomain(
                vitalReadingJpaRepository.save(persistenceMapper.toEntity(reading))
        );
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<VitalReading> findById(UUID id) {
        return vitalReadingJpaRepository.findById(id).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<VitalReading> findLatestByPatientId(UUID patientId) {
        return vitalReadingJpaRepository.findFirstByPatientIdOrderByRecordedAtDesc(patientId)
                .map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<VitalReading> findByPatientId(UUID patientId, Pageable pageable) {
        return vitalReadingJpaRepository.findByPatientId(patientId, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<VitalReading> findByPatientUserId(UUID patientUserId, Pageable pageable) {
        return vitalReadingJpaRepository.findByPatientUserId(patientUserId, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<VitalReading> findAll(Pageable pageable) {
        return vitalReadingJpaRepository.findAll(pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<VitalReading> findByAnomalyDetected(boolean anomalyDetected, Pageable pageable) {
        return vitalReadingJpaRepository.findByAnomalyDetected(anomalyDetected, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByPatientIdAndPatientUserId(UUID patientId, UUID patientUserId) {
        return vitalReadingJpaRepository.existsByPatientIdAndPatientUserId(patientId, patientUserId);
    }
}
