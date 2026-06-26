package com.mednova.appointment.infrastructure.persistence.adapter;

import com.mednova.appointment.domain.model.Appointment;
import com.mednova.appointment.domain.model.AppointmentStatus;
import com.mednova.appointment.domain.port.AppointmentRepository;
import com.mednova.appointment.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.appointment.infrastructure.persistence.repository.AppointmentJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class AppointmentRepositoryAdapter implements AppointmentRepository {

    private final AppointmentJpaRepository appointmentJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public Appointment save(Appointment appointment) {
        return persistenceMapper.toDomain(
                appointmentJpaRepository.save(persistenceMapper.toEntity(appointment))
        );
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Appointment> findById(UUID id) {
        return appointmentJpaRepository.findById(id).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Appointment> findAll(Pageable pageable) {
        return appointmentJpaRepository.findAll(pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Appointment> findByPatientUserId(UUID patientUserId, Pageable pageable) {
        return appointmentJpaRepository.findByPatientUserId(patientUserId, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Appointment> findByDoctorUserId(UUID doctorUserId, Pageable pageable) {
        return appointmentJpaRepository.findByDoctorUserId(doctorUserId, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Appointment> findByPatientId(UUID patientId, Pageable pageable) {
        return appointmentJpaRepository.findByPatientId(patientId, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Appointment> findByDoctorId(UUID doctorId, Pageable pageable) {
        return appointmentJpaRepository.findByDoctorId(doctorId, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Appointment> findByStatus(AppointmentStatus status, Pageable pageable) {
        return appointmentJpaRepository.findByStatus(status, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional
    public void deleteById(UUID id) {
        appointmentJpaRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsById(UUID id) {
        return appointmentJpaRepository.existsById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsDoctorOverlap(UUID doctorId, Instant startAt, Instant endAt, UUID excludeId) {
        return appointmentJpaRepository.existsDoctorOverlap(doctorId, startAt, endAt, excludeId);
    }
}
