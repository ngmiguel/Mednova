package com.mednova.ai.infrastructure.persistence.entity;

import com.mednova.ai.domain.model.RiskLevel;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "risk_assessments")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RiskAssessmentEntity {

    @Id
    private UUID id;

    @Column(name = "patient_id", nullable = false)
    private UUID patientId;

    @Column(name = "patient_user_id")
    private UUID patientUserId;

    @Column(name = "reading_id")
    private UUID readingId;

    @Column(name = "risk_score", nullable = false)
    private int riskScore;

    @Enumerated(EnumType.STRING)
    @Column(name = "risk_level", nullable = false)
    private RiskLevel riskLevel;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String factors;

    @Column(columnDefinition = "TEXT")
    private String recommendation;

    @Column(name = "trigger_event_type")
    private String triggerEventType;

    @Column(name = "correlation_id")
    private String correlationId;

    @Column(name = "assessed_at", nullable = false)
    private Instant assessedAt;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;
}
