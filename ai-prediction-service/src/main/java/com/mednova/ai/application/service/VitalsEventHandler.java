package com.mednova.ai.application.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mednova.ai.domain.model.VitalsSnapshot;
import com.mednova.common.event.EventTypes;
import com.mednova.common.event.payload.VitalsRecordedPayload;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class VitalsEventHandler {

    private final RiskAssessmentApplicationService riskAssessmentApplicationService;
    private final ObjectMapper objectMapper;

    public void handle(String rawMessage) {
        try {
            JsonNode root = objectMapper.readTree(rawMessage);
            String eventType = text(root, "eventType");
            String correlationId = text(root, "correlationId");

            if (!EventTypes.VITALS_RECORDED.equals(eventType)) {
                return;
            }

            JsonNode payload = root.path("payload");
            VitalsSnapshot snapshot = mapVitals(payload);
            if (snapshot.getPatientId() == null) {
                log.warn("Événement vitals ignoré : patientId manquant");
                return;
            }

            riskAssessmentApplicationService.assessFromVitals(snapshot, eventType, correlationId);
        } catch (Exception ex) {
            log.error("Erreur traitement événement vitals : {}", ex.getMessage());
        }
    }

    private VitalsSnapshot mapVitals(JsonNode payload) {
        VitalsRecordedPayload vitals = objectMapper.convertValue(payload, VitalsRecordedPayload.class);
        return VitalsSnapshot.builder()
                .readingId(vitals.readingId())
                .patientId(vitals.patientId())
                .patientUserId(vitals.patientUserId())
                .heartRate(vitals.heartRate())
                .systolicBp(vitals.systolicBp())
                .diastolicBp(vitals.diastolicBp())
                .temperature(vitals.temperature())
                .oxygenSaturation(vitals.oxygenSaturation())
                .anomalyDetected(vitals.anomalyDetected())
                .build();
    }

    private String text(JsonNode node, String field) {
        JsonNode value = node.path(field);
        return value.isMissingNode() || value.isNull() ? null : value.asText();
    }
}
