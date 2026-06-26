package com.mednova.audit.infrastructure.kafka;

import com.mednova.audit.application.service.AuditIngestionService;
import com.mednova.common.event.KafkaTopics;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DomainEventConsumer {

    private final AuditIngestionService auditIngestionService;

    @KafkaListener(topics = KafkaTopics.DOMAIN_EVENTS, groupId = "audit-service")
    public void consume(String message) {
        auditIngestionService.ingest(message);
    }
}
