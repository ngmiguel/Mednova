package com.mednova.patient.infrastructure.persistence.entity;

import com.mednova.patient.domain.model.AllergySeverity;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "allergies")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AllergyEntity {

    @Id
    private UUID id;

    @Column(name = "patient_id", nullable = false)
    private UUID patientId;

    @Column(nullable = false)
    private String allergen;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AllergySeverity severity;

    private String reaction;

    @Column(name = "diagnosed_at")
    private LocalDate diagnosedAt;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;
}
