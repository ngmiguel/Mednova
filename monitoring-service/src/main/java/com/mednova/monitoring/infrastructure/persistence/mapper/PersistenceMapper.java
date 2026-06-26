package com.mednova.monitoring.infrastructure.persistence.mapper;

import com.mednova.monitoring.domain.model.VitalReading;
import com.mednova.monitoring.infrastructure.persistence.entity.VitalReadingEntity;
import org.springframework.stereotype.Component;

@Component
public class PersistenceMapper {

    public VitalReading toDomain(VitalReadingEntity entity) {
        return VitalReading.builder()
                .id(entity.getId())
                .patientId(entity.getPatientId())
                .patientUserId(entity.getPatientUserId())
                .heartRate(entity.getHeartRate())
                .systolicBp(entity.getSystolicBp())
                .diastolicBp(entity.getDiastolicBp())
                .temperature(entity.getTemperature())
                .oxygenSaturation(entity.getOxygenSaturation())
                .anomalyDetected(entity.isAnomalyDetected())
                .anomalyDetails(entity.getAnomalyDetails())
                .recordedAt(entity.getRecordedAt())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public VitalReadingEntity toEntity(VitalReading reading) {
        return VitalReadingEntity.builder()
                .id(reading.getId())
                .patientId(reading.getPatientId())
                .patientUserId(reading.getPatientUserId())
                .heartRate(reading.getHeartRate())
                .systolicBp(reading.getSystolicBp())
                .diastolicBp(reading.getDiastolicBp())
                .temperature(reading.getTemperature())
                .oxygenSaturation(reading.getOxygenSaturation())
                .anomalyDetected(reading.isAnomalyDetected())
                .anomalyDetails(reading.getAnomalyDetails())
                .recordedAt(reading.getRecordedAt())
                .createdAt(reading.getCreatedAt())
                .build();
    }
}
