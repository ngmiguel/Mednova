package com.mednova.appointment.infrastructure.persistence.mapper;

import com.mednova.appointment.domain.model.Appointment;
import com.mednova.appointment.infrastructure.persistence.entity.AppointmentEntity;
import org.springframework.stereotype.Component;

@Component
public class PersistenceMapper {

    public Appointment toDomain(AppointmentEntity entity) {
        return Appointment.builder()
                .id(entity.getId())
                .patientId(entity.getPatientId())
                .doctorId(entity.getDoctorId())
                .patientUserId(entity.getPatientUserId())
                .doctorUserId(entity.getDoctorUserId())
                .scheduledAt(entity.getScheduledAt())
                .durationMinutes(entity.getDurationMinutes())
                .reason(entity.getReason())
                .notes(entity.getNotes())
                .status(entity.getStatus())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    public AppointmentEntity toEntity(Appointment appointment) {
        return AppointmentEntity.builder()
                .id(appointment.getId())
                .patientId(appointment.getPatientId())
                .doctorId(appointment.getDoctorId())
                .patientUserId(appointment.getPatientUserId())
                .doctorUserId(appointment.getDoctorUserId())
                .scheduledAt(appointment.getScheduledAt())
                .durationMinutes(appointment.getDurationMinutes())
                .reason(appointment.getReason())
                .notes(appointment.getNotes())
                .status(appointment.getStatus())
                .createdAt(appointment.getCreatedAt())
                .updatedAt(appointment.getUpdatedAt())
                .build();
    }
}
