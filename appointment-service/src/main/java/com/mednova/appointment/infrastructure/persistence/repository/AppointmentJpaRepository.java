package com.mednova.appointment.infrastructure.persistence.repository;

import com.mednova.appointment.domain.model.AppointmentStatus;
import com.mednova.appointment.infrastructure.persistence.entity.AppointmentEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.UUID;

public interface AppointmentJpaRepository extends JpaRepository<AppointmentEntity, UUID> {

    Page<AppointmentEntity> findByPatientUserId(UUID patientUserId, Pageable pageable);

    Page<AppointmentEntity> findByDoctorUserId(UUID doctorUserId, Pageable pageable);

    Page<AppointmentEntity> findByPatientId(UUID patientId, Pageable pageable);

    Page<AppointmentEntity> findByDoctorId(UUID doctorId, Pageable pageable);

    Page<AppointmentEntity> findByStatus(AppointmentStatus status, Pageable pageable);

    @Query(value = """
            SELECT EXISTS (
                SELECT 1 FROM appointments a
                WHERE a.doctor_id = :doctorId
                  AND a.status IN ('SCHEDULED', 'CONFIRMED')
                  AND (:excludeId IS NULL OR a.id <> :excludeId)
                  AND a.scheduled_at < :endAt
                  AND a.scheduled_at + (a.duration_minutes * INTERVAL '1 minute') > :startAt
            )
            """, nativeQuery = true)
    boolean existsDoctorOverlap(
            @Param("doctorId") UUID doctorId,
            @Param("startAt") Instant startAt,
            @Param("endAt") Instant endAt,
            @Param("excludeId") UUID excludeId
    );
}
