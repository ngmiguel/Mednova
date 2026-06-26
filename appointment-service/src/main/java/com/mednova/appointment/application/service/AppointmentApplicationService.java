package com.mednova.appointment.application.service;

import com.mednova.appointment.application.security.AppointmentAccessGuard;
import com.mednova.appointment.domain.model.Appointment;
import com.mednova.appointment.domain.model.AppointmentStatus;
import com.mednova.appointment.domain.port.AppointmentRepository;
import com.mednova.appointment.infrastructure.kafka.AppointmentEventPublisher;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.exception.BusinessException;
import com.mednova.common.exception.ConflictException;
import com.mednova.common.exception.ForbiddenException;
import com.mednova.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AppointmentApplicationService {

    private final AppointmentRepository appointmentRepository;
    private final AppointmentAccessGuard accessGuard;
    private final AppointmentEventPublisher appointmentEventPublisher;

    @Transactional
    public Appointment create(Appointment appointment) {
        accessGuard.checkCanCreate();

        UUID patientUserId = resolvePatientUserId(appointment.getPatientUserId());
        validateScheduledAt(appointment.getScheduledAt());
        validateDuration(appointment.getDurationMinutes());

        Instant endAt = appointment.getScheduledAt().plus(appointment.getDurationMinutes(), ChronoUnit.MINUTES);
        if (appointmentRepository.existsDoctorOverlap(
                appointment.getDoctorId(), appointment.getScheduledAt(), endAt, null)) {
            throw new ConflictException("Ce créneau chevauche un rendez-vous existant pour ce médecin");
        }

        Appointment toSave = Appointment.builder()
                .id(UUID.randomUUID())
                .patientId(appointment.getPatientId())
                .doctorId(appointment.getDoctorId())
                .patientUserId(patientUserId)
                .doctorUserId(appointment.getDoctorUserId())
                .scheduledAt(appointment.getScheduledAt())
                .durationMinutes(appointment.getDurationMinutes())
                .reason(appointment.getReason())
                .notes(appointment.getNotes())
                .status(AppointmentStatus.SCHEDULED)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        Appointment saved = appointmentRepository.save(toSave);
        appointmentEventPublisher.publishScheduled(saved, null);
        return saved;
    }

    @Transactional(readOnly = true)
    public Appointment getById(UUID id) {
        Appointment appointment = appointmentRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Rendez-vous", id));
        accessGuard.checkCanRead(appointment);
        return appointment;
    }

    @Transactional(readOnly = true)
    public PageResponse<Appointment> list(
            UUID patientId,
            UUID doctorId,
            AppointmentStatus status,
            Pageable pageable
    ) {
        accessGuard.checkCanList();
        Page<Appointment> page = resolveListPage(patientId, doctorId, status, pageable);
        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional
    public Appointment update(UUID id, Appointment updates) {
        Appointment existing = appointmentRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Rendez-vous", id));
        accessGuard.checkCanUpdate(existing);

        if (!existing.isActive()) {
            throw new BusinessException("Seuls les rendez-vous planifiés ou confirmés peuvent être modifiés");
        }

        Instant scheduledAt = updates.getScheduledAt() != null ? updates.getScheduledAt() : existing.getScheduledAt();
        int durationMinutes = updates.getDurationMinutes() > 0 ? updates.getDurationMinutes() : existing.getDurationMinutes();

        validateScheduledAt(scheduledAt);
        validateDuration(durationMinutes);

        Instant endAt = scheduledAt.plus(durationMinutes, ChronoUnit.MINUTES);
        if (appointmentRepository.existsDoctorOverlap(existing.getDoctorId(), scheduledAt, endAt, existing.getId())) {
            throw new ConflictException("Ce créneau chevauche un rendez-vous existant pour ce médecin");
        }

        Appointment updated = Appointment.builder()
                .id(existing.getId())
                .patientId(existing.getPatientId())
                .doctorId(existing.getDoctorId())
                .patientUserId(existing.getPatientUserId())
                .doctorUserId(existing.getDoctorUserId())
                .scheduledAt(scheduledAt)
                .durationMinutes(durationMinutes)
                .reason(updates.getReason() != null ? updates.getReason() : existing.getReason())
                .notes(updates.getNotes() != null ? updates.getNotes() : existing.getNotes())
                .status(existing.getStatus())
                .createdAt(existing.getCreatedAt())
                .updatedAt(Instant.now())
                .build();

        return appointmentRepository.save(updated);
    }

    @Transactional
    public Appointment cancel(UUID id) {
        Appointment existing = appointmentRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Rendez-vous", id));
        accessGuard.checkCanCancel(existing);

        if (existing.getStatus() == AppointmentStatus.CANCELLED) {
            throw new BusinessException("Ce rendez-vous est déjà annulé");
        }
        if (existing.getStatus() == AppointmentStatus.COMPLETED) {
            throw new BusinessException("Un rendez-vous terminé ne peut pas être annulé");
        }

        Appointment cancelled = appointmentRepository.save(copyWithStatus(existing, AppointmentStatus.CANCELLED));
        appointmentEventPublisher.publishCancelled(cancelled, null);
        return cancelled;
    }

    @Transactional
    public Appointment confirm(UUID id) {
        Appointment existing = appointmentRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Rendez-vous", id));
        accessGuard.checkCanConfirm(existing);

        if (existing.getStatus() != AppointmentStatus.SCHEDULED) {
            throw new BusinessException("Seuls les rendez-vous planifiés peuvent être confirmés");
        }

        return appointmentRepository.save(copyWithStatus(existing, AppointmentStatus.CONFIRMED));
    }

    @Transactional
    public void delete(UUID id) {
        accessGuard.checkCanDelete();
        if (!appointmentRepository.existsById(id)) {
            throw ResourceNotFoundException.forResource("Rendez-vous", id);
        }
        appointmentRepository.deleteById(id);
    }

    private Page<Appointment> resolveListPage(
            UUID patientId,
            UUID doctorId,
            AppointmentStatus status,
            Pageable pageable
    ) {
        if (accessGuard.isPatient()) {
            return appointmentRepository.findByPatientUserId(accessGuard.currentUserId(), pageable);
        }
        if (accessGuard.isDoctor()) {
            return appointmentRepository.findByDoctorUserId(accessGuard.currentUserId(), pageable);
        }

        if (patientId != null) {
            return appointmentRepository.findByPatientId(patientId, pageable);
        }
        if (doctorId != null) {
            return appointmentRepository.findByDoctorId(doctorId, pageable);
        }
        if (status != null) {
            return appointmentRepository.findByStatus(status, pageable);
        }
        return appointmentRepository.findAll(pageable);
    }

    private UUID resolvePatientUserId(UUID requestedPatientUserId) {
        if (accessGuard.isPatient()) {
            UUID currentUserId = accessGuard.currentUserId();
            if (requestedPatientUserId != null && !requestedPatientUserId.equals(currentUserId)) {
                throw new ForbiddenException("Un patient ne peut planifier un rendez-vous que pour lui-même");
            }
            return currentUserId;
        }
        if (requestedPatientUserId == null) {
            throw new BusinessException("L'identifiant utilisateur patient est requis");
        }
        return requestedPatientUserId;
    }

    private void validateScheduledAt(Instant scheduledAt) {
        if (scheduledAt == null) {
            throw new BusinessException("La date du rendez-vous est requise");
        }
        if (scheduledAt.isBefore(Instant.now())) {
            throw new BusinessException("La date du rendez-vous doit être dans le futur");
        }
    }

    private void validateDuration(int durationMinutes) {
        if (durationMinutes <= 0 || durationMinutes > 480) {
            throw new BusinessException("La durée doit être comprise entre 1 et 480 minutes");
        }
    }

    private Appointment copyWithStatus(Appointment existing, AppointmentStatus status) {
        return Appointment.builder()
                .id(existing.getId())
                .patientId(existing.getPatientId())
                .doctorId(existing.getDoctorId())
                .patientUserId(existing.getPatientUserId())
                .doctorUserId(existing.getDoctorUserId())
                .scheduledAt(existing.getScheduledAt())
                .durationMinutes(existing.getDurationMinutes())
                .reason(existing.getReason())
                .notes(existing.getNotes())
                .status(status)
                .createdAt(existing.getCreatedAt())
                .updatedAt(Instant.now())
                .build();
    }
}
