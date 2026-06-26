package com.mednova.patient.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class Treatment {

    private UUID id;
    private UUID patientId;
    private String medication;
    private String dosage;
    private String frequency;
    private LocalDate startDate;
    private LocalDate endDate;
    private UUID prescribedBy;
    private boolean active;
    private Instant createdAt;
}
