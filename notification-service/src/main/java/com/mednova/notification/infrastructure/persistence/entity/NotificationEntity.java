package com.mednova.notification.infrastructure.persistence.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationEntity {

    @Id
    private UUID id;

    @Column(name = "patient_id")
    private UUID patientId;

    @Column(nullable = false, length = 40)
    private String type;

    @Column(nullable = false, length = 20)
    private String channel;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(nullable = false, length = 20)
    private String status;

    @Column(name = "target_role", length = 30)
    private String targetRole;

    @Column(name = "source_event_type", length = 80)
    private String sourceEventType;

    @Column(name = "correlation_id", length = 64)
    private String correlationId;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "read_at")
    private Instant readAt;
}
