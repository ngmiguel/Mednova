package com.mednova.patient.infrastructure.persistence.adapter;

import com.mednova.patient.domain.model.Patient;
import com.mednova.patient.domain.port.PatientRepository;
import com.mednova.patient.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.patient.infrastructure.persistence.repository.PatientJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class PatientRepositoryAdapter implements PatientRepository {

    private final PatientJpaRepository patientJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public Patient save(Patient patient) {
        return persistenceMapper.toDomain(patientJpaRepository.save(persistenceMapper.toEntity(patient)));
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Patient> findById(UUID id) {
        return patientJpaRepository.findById(id).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Patient> findByUserId(UUID userId) {
        return patientJpaRepository.findByUserId(userId).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Patient> findAll(Pageable pageable) {
        return patientJpaRepository.findAll(pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional
    public void deleteById(UUID id) {
        patientJpaRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsById(UUID id) {
        return patientJpaRepository.existsById(id);
    }
}
