package com.mednova.monitoring.infrastructure.kafka;

import com.mednova.common.event.EventTypes;
import com.mednova.common.event.payload.VitalsAnomalyDetectedPayload;
import com.mednova.common.event.payload.VitalsRecordedPayload;
import com.mednova.monitoring.domain.model.VitalReading;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class VitalEventPublisher {

    private final DomainEventPublisher domainEventPublisher;

    public void publishVitalsRecorded(VitalReading reading, String correlationId) {
        String correlation = correlationId != null ? correlationId : UUID.randomUUID().toString();

        domainEventPublisher.publish(
                EventTypes.VITALS_RECORDED,
                correlation,
                new VitalsRecordedPayload(
                        reading.getId(),
                        reading.getPatientId(),
                        reading.getPatientUserId(),
                        reading.getHeartRate(),
                        reading.getSystolicBp(),
                        reading.getDiastolicBp(),
                        reading.getTemperature(),
                        reading.getOxygenSaturation(),
                        reading.isAnomalyDetected(),
                        reading.getRecordedAt()
                )
        );

        if (reading.isAnomalyDetected()) {
            domainEventPublisher.publish(
                    EventTypes.VITALS_ANOMALY_DETECTED,
                    correlation,
                    new VitalsAnomalyDetectedPayload(
                            reading.getId(),
                            reading.getPatientId(),
                            reading.getAnomalyDetails()
                    )
            );
        }
    }
}
