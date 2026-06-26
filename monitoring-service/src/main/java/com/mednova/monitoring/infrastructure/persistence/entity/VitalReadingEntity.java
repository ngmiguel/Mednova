package com.mednova.monitoring.infrastructure.persistence.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "vital_readings")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VitalReadingEntity {

    @Id
    private UUID id;

    @Column(name = "patient_id", nullable = false)
    private UUID patientId;

    @Column(name = "patient_user_id")
    private UUID patientUserId;

    @Column(name = "heart_rate")
    private Integer heartRate;

    @Column(name = "systolic_bp")
    private Integer systolicBp;

    @Column(name = "diastolic_bp")
    private Integer diastolicBp;

    private BigDecimal temperature;

    @Column(name = "oxygen_saturation")
    private Integer oxygenSaturation;

    @Column(name = "anomaly_detected", nullable = false)
    private boolean anomalyDetected;

    @Column(name = "anomaly_details", columnDefinition = "TEXT")
    private String anomalyDetails;

    @Column(name = "recorded_at", nullable = false)
    private Instant recordedAt;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;
}
