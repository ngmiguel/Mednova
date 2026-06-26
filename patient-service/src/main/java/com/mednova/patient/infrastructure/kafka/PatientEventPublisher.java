package com.mednova.patient.infrastructure.kafka;

import com.mednova.common.event.EventTypes;
import com.mednova.common.event.payload.PatientCreatedPayload;
import com.mednova.patient.domain.model.Patient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class PatientEventPublisher {

    private final DomainEventPublisher domainEventPublisher;

    public void publishCreated(Patient patient, String correlationId) {
        domainEventPublisher.publish(
                EventTypes.PATIENT_CREATED,
                correlationId != null ? correlationId : UUID.randomUUID().toString(),
                new PatientCreatedPayload(
                        patient.getId(),
                        patient.getUserId(),
                        patient.getFirstName(),
                        patient.getLastName(),
                        patient.getEmail()
                )
        );
    }
}
