package com.mednova.appointment.infrastructure.kafka;

import com.mednova.appointment.domain.model.Appointment;
import com.mednova.common.event.EventTypes;
import com.mednova.common.event.payload.AppointmentCancelledPayload;
import com.mednova.common.event.payload.AppointmentScheduledPayload;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class AppointmentEventPublisher {

    private final DomainEventPublisher domainEventPublisher;

    public void publishScheduled(Appointment appointment, String correlationId) {
        domainEventPublisher.publish(
                EventTypes.APPOINTMENT_SCHEDULED,
                correlationId != null ? correlationId : UUID.randomUUID().toString(),
                new AppointmentScheduledPayload(
                        appointment.getId(),
                        appointment.getPatientId(),
                        appointment.getDoctorId(),
                        appointment.getScheduledAt(),
                        appointment.getReason()
                )
        );
    }

    public void publishCancelled(Appointment appointment, String correlationId) {
        domainEventPublisher.publish(
                EventTypes.APPOINTMENT_CANCELLED,
                correlationId != null ? correlationId : UUID.randomUUID().toString(),
                new AppointmentCancelledPayload(
                        appointment.getId(),
                        appointment.getPatientId(),
                        appointment.getDoctorId(),
                        appointment.getReason()
                )
        );
    }
}
