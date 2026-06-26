package com.mednova.audit.application.service;

import com.mednova.audit.domain.model.AuditEvent;
import com.mednova.audit.domain.port.AuditEventRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuditIngestionService {

    private final AuditEventRepository auditEventRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public void ingest(String rawMessage) {
        try {
            JsonNode root = objectMapper.readTree(rawMessage);
            String eventId = text(root, "eventId");
            if (eventId == null) {
                log.warn("Message Kafka ignoré : eventId manquant");
                return;
            }
            if (auditEventRepository.findByEventId(eventId).isPresent()) {
                log.debug("Événement déjà traité : {}", eventId);
                return;
            }

            AuditEvent event = AuditEvent.builder()
                    .id(UUID.randomUUID())
                    .eventId(eventId)
                    .eventType(text(root, "eventType"))
                    .source(text(root, "source"))
                    .correlationId(text(root, "correlationId"))
                    .payload(root.path("payload").isMissingNode() ? "{}" : root.path("payload").toString())
                    .receivedAt(Instant.now())
                    .build();

            auditEventRepository.save(event);
            log.info("Audit enregistré : {} [{}]", event.getEventType(), event.getEventId());
        } catch (Exception ex) {
            log.error("Erreur lors de l'ingestion d'un événement Kafka : {}", ex.getMessage());
        }
    }

    private String text(JsonNode node, String field) {
        JsonNode value = node.path(field);
        return value.isMissingNode() || value.isNull() ? null : value.asText();
    }
}
