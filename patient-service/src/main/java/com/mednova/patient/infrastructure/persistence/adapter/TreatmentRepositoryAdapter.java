package com.mednova.patient.infrastructure.persistence.adapter;

import com.mednova.patient.domain.model.Treatment;
import com.mednova.patient.domain.port.TreatmentRepository;
import com.mednova.patient.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.patient.infrastructure.persistence.repository.TreatmentJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class TreatmentRepositoryAdapter implements TreatmentRepository {

    private final TreatmentJpaRepository jpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public Treatment save(Treatment treatment) {
        return persistenceMapper.toDomain(jpaRepository.save(persistenceMapper.toEntity(treatment)));
    }

    @Override
    @Transactional(readOnly = true)
    public List<Treatment> findByPatientId(UUID patientId) {
        return jpaRepository.findByPatientIdOrderByStartDateDesc(patientId).stream()
                .map(persistenceMapper::toDomain)
                .toList();
    }
}
