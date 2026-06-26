package com.mednova.notification.infrastructure.kafka;

import com.mednova.common.event.KafkaTopics;
import com.mednova.notification.application.service.DomainEventHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DomainEventConsumer {

    private final DomainEventHandler domainEventHandler;

    @KafkaListener(topics = KafkaTopics.DOMAIN_EVENTS, groupId = "notification-service")
    public void consume(String message) {
        domainEventHandler.handle(message);
    }
}
