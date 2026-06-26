package com.mednova.doctor.infrastructure.persistence.repository;

import com.mednova.doctor.infrastructure.persistence.entity.AvailabilityEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AvailabilityJpaRepository extends JpaRepository<AvailabilityEntity, UUID> {

    List<AvailabilityEntity> findByDoctorIdOrderByDayOfWeekAscStartTimeAsc(UUID doctorId);

    Optional<AvailabilityEntity> findByIdAndDoctorId(UUID id, UUID doctorId);
}
