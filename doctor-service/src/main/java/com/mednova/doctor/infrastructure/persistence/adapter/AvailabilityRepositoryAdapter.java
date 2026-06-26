package com.mednova.doctor.infrastructure.persistence.adapter;

import com.mednova.doctor.domain.model.Availability;
import com.mednova.doctor.domain.port.AvailabilityRepository;
import com.mednova.doctor.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.doctor.infrastructure.persistence.repository.AvailabilityJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class AvailabilityRepositoryAdapter implements AvailabilityRepository {

    private final AvailabilityJpaRepository availabilityJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public Availability save(Availability availability) {
        return persistenceMapper.toDomain(availabilityJpaRepository.save(persistenceMapper.toEntity(availability)));
    }

    @Override
    @Transactional(readOnly = true)
    public List<Availability> findByDoctorId(UUID doctorId) {
        return availabilityJpaRepository.findByDoctorIdOrderByDayOfWeekAscStartTimeAsc(doctorId).stream()
                .map(persistenceMapper::toDomain)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Availability> findByIdAndDoctorId(UUID id, UUID doctorId) {
        return availabilityJpaRepository.findByIdAndDoctorId(id, doctorId).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional
    public void deleteById(UUID id) {
        availabilityJpaRepository.deleteById(id);
    }
}
