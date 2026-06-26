package com.mednova.monitoring.application.service;

import com.mednova.monitoring.domain.model.VitalReading;
import com.mednova.monitoring.presentation.dto.VitalAlertMessage;
import com.mednova.monitoring.presentation.dto.VitalReadingResponse;
import com.mednova.monitoring.presentation.mapper.VitalReadingMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VitalBroadcastService {

    private final SimpMessagingTemplate messagingTemplate;
    private final VitalReadingMapper vitalReadingMapper;

    public void broadcastReading(VitalReading reading) {
        VitalReadingResponse response = vitalReadingMapper.toResponse(reading);
        messagingTemplate.convertAndSend(patientTopic(reading.getPatientId()), response);

        if (reading.isAnomalyDetected()) {
            VitalAlertMessage alert = new VitalAlertMessage(
                    reading.getId(),
                    reading.getPatientId(),
                    reading.getAnomalyDetails(),
                    response
            );
            messagingTemplate.convertAndSend("/topic/monitoring/alerts", alert);
        }
    }

    public static String patientTopic(UUID patientId) {
        return "/topic/patients/" + patientId + "/vitals";
    }
}
