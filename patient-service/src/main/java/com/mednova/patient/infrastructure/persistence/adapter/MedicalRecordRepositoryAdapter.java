package com.mednova.patient.infrastructure.persistence.adapter;

import com.mednova.patient.domain.model.MedicalRecord;
import com.mednova.patient.domain.port.MedicalRecordRepository;
import com.mednova.patient.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.patient.infrastructure.persistence.repository.MedicalRecordJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class MedicalRecordRepositoryAdapter implements MedicalRecordRepository {

    private final MedicalRecordJpaRepository jpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public MedicalRecord save(MedicalRecord record) {
        return persistenceMapper.toDomain(jpaRepository.save(persistenceMapper.toEntity(record)));
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<MedicalRecord> findByIdAndPatientId(UUID id, UUID patientId) {
        return jpaRepository.findByIdAndPatientId(id, patientId).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MedicalRecord> findByPatientId(UUID patientId) {
        return jpaRepository.findByPatientIdOrderByVisitDateDesc(patientId).stream()
                .map(persistenceMapper::toDomain)
                .toList();
    }
}
