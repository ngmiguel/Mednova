package com.mednova.patient.infrastructure.kafka;

import com.mednova.common.event.BaseEvent;
import com.mednova.common.event.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DomainEventPublisher {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${spring.application.name}")
    private String serviceName;

    public <T> void publish(String eventType, String correlationId, T payload) {
        try {
            BaseEvent<T> event = BaseEvent.of(eventType, serviceName, correlationId, payload);
            kafkaTemplate.send(KafkaTopics.DOMAIN_EVENTS, event.eventId(), event);
            log.debug("Event published: {} [{}]", eventType, event.eventId());
        } catch (Exception ex) {
            log.warn("Échec de publication Kafka pour {} : {}", eventType, ex.getMessage());
        }
    }
}
