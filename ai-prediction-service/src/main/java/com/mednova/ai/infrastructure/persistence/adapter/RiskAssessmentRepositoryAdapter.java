package com.mednova.ai.infrastructure.persistence.adapter;

import com.mednova.ai.domain.model.RiskAssessment;
import com.mednova.ai.domain.port.RiskAssessmentRepository;
import com.mednova.ai.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.ai.infrastructure.persistence.repository.RiskAssessmentJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class RiskAssessmentRepositoryAdapter implements RiskAssessmentRepository {

    private final RiskAssessmentJpaRepository riskAssessmentJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public RiskAssessment save(RiskAssessment assessment) {
        return persistenceMapper.toDomain(
                riskAssessmentJpaRepository.save(persistenceMapper.toEntity(assessment))
        );
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<RiskAssessment> findById(UUID id) {
        return riskAssessmentJpaRepository.findById(id).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<RiskAssessment> findLatestByPatientId(UUID patientId) {
        return riskAssessmentJpaRepository.findFirstByPatientIdOrderByAssessedAtDesc(patientId)
                .map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<RiskAssessment> findByPatientId(UUID patientId, Pageable pageable) {
        return riskAssessmentJpaRepository.findByPatientId(patientId, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<RiskAssessment> findByPatientUserId(UUID patientUserId, Pageable pageable) {
        return riskAssessmentJpaRepository.findByPatientUserId(patientUserId, pageable).map(persistenceMapper::toDomain);
    }
}
