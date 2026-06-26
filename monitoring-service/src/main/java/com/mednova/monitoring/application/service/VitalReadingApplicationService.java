package com.mednova.monitoring.application.service;

import com.mednova.common.dto.PageResponse;
import com.mednova.common.exception.BusinessException;
import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.monitoring.application.security.MonitoringAccessGuard;
import com.mednova.monitoring.domain.model.VitalReading;
import com.mednova.monitoring.domain.port.VitalReadingRepository;
import com.mednova.monitoring.infrastructure.kafka.VitalEventPublisher;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VitalReadingApplicationService {

    private final VitalReadingRepository vitalReadingRepository;
    private final MonitoringAccessGuard accessGuard;
    private final AnomalyDetectionService anomalyDetectionService;
    private final VitalBroadcastService vitalBroadcastService;
    private final VitalEventPublisher vitalEventPublisher;

    @Transactional
    public VitalReading record(VitalReading reading) {
        accessGuard.checkCanRecord();

        if (reading.getPatientId() == null) {
            throw new BusinessException("L'identifiant patient est requis");
        }
        if (reading.getHeartRate() == null && reading.getSystolicBp() == null
                && reading.getDiastolicBp() == null && reading.getTemperature() == null
                && reading.getOxygenSaturation() == null) {
            throw new BusinessException("Au moins une constante vitale doit être renseignée");
        }

        Instant recordedAt = reading.getRecordedAt() != null ? reading.getRecordedAt() : Instant.now();

        VitalReading draft = VitalReading.builder()
                .id(UUID.randomUUID())
                .patientId(reading.getPatientId())
                .patientUserId(reading.getPatientUserId())
                .heartRate(reading.getHeartRate())
                .systolicBp(reading.getSystolicBp())
                .diastolicBp(reading.getDiastolicBp())
                .temperature(reading.getTemperature())
                .oxygenSaturation(reading.getOxygenSaturation())
                .anomalyDetected(false)
                .anomalyDetails(null)
                .recordedAt(recordedAt)
                .createdAt(Instant.now())
                .build();

        var anomaly = anomalyDetectionService.analyze(draft);
        VitalReading toSave = VitalReading.builder()
                .id(draft.getId())
                .patientId(draft.getPatientId())
                .patientUserId(draft.getPatientUserId())
                .heartRate(draft.getHeartRate())
                .systolicBp(draft.getSystolicBp())
                .diastolicBp(draft.getDiastolicBp())
                .temperature(draft.getTemperature())
                .oxygenSaturation(draft.getOxygenSaturation())
                .anomalyDetected(anomaly.detected())
                .anomalyDetails(anomaly.details())
                .recordedAt(draft.getRecordedAt())
                .createdAt(draft.getCreatedAt())
                .build();

        VitalReading saved = vitalReadingRepository.save(toSave);
        vitalBroadcastService.broadcastReading(saved);
        vitalEventPublisher.publishVitalsRecorded(saved, null);
        return saved;
    }

    @Transactional(readOnly = true)
    public VitalReading getById(UUID id) {
        VitalReading reading = vitalReadingRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Constante vitale", id));
        accessGuard.checkCanRead(reading);
        return reading;
    }

    @Transactional(readOnly = true)
    public VitalReading getLatestByPatientId(UUID patientId) {
        VitalReading reading = vitalReadingRepository.findLatestByPatientId(patientId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Constante vitale", patientId));
        accessGuard.checkCanRead(reading);
        return reading;
    }

    @Transactional(readOnly = true)
    public PageResponse<VitalReading> listByPatient(UUID patientId, UUID patientUserId, Pageable pageable) {
        accessGuard.checkCanReadPatient(patientId, patientUserId);

        Page<VitalReading> page = accessGuard.isPatient()
                ? vitalReadingRepository.findByPatientUserId(accessGuard.currentUserId(), pageable)
                : vitalReadingRepository.findByPatientId(patientId, pageable);

        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public PageResponse<VitalReading> listAnomalies(Pageable pageable) {
        accessGuard.checkCanListAnomalies();
        Page<VitalReading> page = vitalReadingRepository.findByAnomalyDetected(true, pageable);
        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }
}
