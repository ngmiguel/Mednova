package com.mednova.ai.infrastructure.kafka;

import com.mednova.ai.application.service.VitalsEventHandler;
import com.mednova.common.event.KafkaTopics;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class VitalsEventConsumer {

    private final VitalsEventHandler vitalsEventHandler;

    @KafkaListener(topics = KafkaTopics.DOMAIN_EVENTS, groupId = "ai-prediction-service")
    public void consume(String message) {
        vitalsEventHandler.handle(message);
    }
}
