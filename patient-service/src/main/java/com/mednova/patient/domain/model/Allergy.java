package com.mednova.patient.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class Allergy {

    private UUID id;
    private UUID patientId;
    private String allergen;
    private AllergySeverity severity;
    private String reaction;
    private LocalDate diagnosedAt;
    private Instant createdAt;
}
