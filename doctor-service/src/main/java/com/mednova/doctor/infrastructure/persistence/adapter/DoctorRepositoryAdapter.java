package com.mednova.doctor.infrastructure.persistence.adapter;

import com.mednova.doctor.domain.model.Doctor;
import com.mednova.doctor.domain.model.Specialty;
import com.mednova.doctor.domain.port.DoctorRepository;
import com.mednova.doctor.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.doctor.infrastructure.persistence.repository.DoctorJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class DoctorRepositoryAdapter implements DoctorRepository {

    private final DoctorJpaRepository doctorJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public Doctor save(Doctor doctor) {
        return persistenceMapper.toDomain(doctorJpaRepository.save(persistenceMapper.toEntity(doctor)));
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Doctor> findById(UUID id) {
        return doctorJpaRepository.findById(id).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Doctor> findAll(Pageable pageable) {
        return doctorJpaRepository.findAll(pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Doctor> findBySpecialty(Specialty specialty, Pageable pageable) {
        return doctorJpaRepository.findBySpecialty(specialty, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional
    public void deleteById(UUID id) {
        doctorJpaRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsById(UUID id) {
        return doctorJpaRepository.existsById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByLicenseNumber(String licenseNumber) {
        return doctorJpaRepository.existsByLicenseNumber(licenseNumber);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return doctorJpaRepository.existsByEmail(email);
    }
}
