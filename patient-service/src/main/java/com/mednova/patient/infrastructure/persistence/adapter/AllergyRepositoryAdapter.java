package com.mednova.patient.infrastructure.persistence.adapter;

import com.mednova.patient.domain.model.Allergy;
import com.mednova.patient.domain.port.AllergyRepository;
import com.mednova.patient.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.patient.infrastructure.persistence.repository.AllergyJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class AllergyRepositoryAdapter implements AllergyRepository {

    private final AllergyJpaRepository jpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public Allergy save(Allergy allergy) {
        return persistenceMapper.toDomain(jpaRepository.save(persistenceMapper.toEntity(allergy)));
    }

    @Override
    @Transactional(readOnly = true)
    public List<Allergy> findByPatientId(UUID patientId) {
        return jpaRepository.findByPatientIdOrderByCreatedAtDesc(patientId).stream()
                .map(persistenceMapper::toDomain)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Allergy> findByIdAndPatientId(UUID id, UUID patientId) {
        return jpaRepository.findByIdAndPatientId(id, patientId).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional
    public void deleteById(UUID id) {
        jpaRepository.deleteById(id);
    }
}
