package com.mednova.appointment.domain.port;

import com.mednova.appointment.domain.model.Appointment;
import com.mednova.appointment.domain.model.AppointmentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public interface AppointmentRepository {

    Appointment save(Appointment appointment);

    Optional<Appointment> findById(UUID id);

    Page<Appointment> findAll(Pageable pageable);

    Page<Appointment> findByPatientUserId(UUID patientUserId, Pageable pageable);

    Page<Appointment> findByDoctorUserId(UUID doctorUserId, Pageable pageable);

    Page<Appointment> findByPatientId(UUID patientId, Pageable pageable);

    Page<Appointment> findByDoctorId(UUID doctorId, Pageable pageable);

    Page<Appointment> findByStatus(AppointmentStatus status, Pageable pageable);

    void deleteById(UUID id);

    boolean existsById(UUID id);

    boolean existsDoctorOverlap(UUID doctorId, Instant startAt, Instant endAt, UUID excludeId);
}
