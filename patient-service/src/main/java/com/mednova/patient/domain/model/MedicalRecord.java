package com.mednova.patient.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class MedicalRecord {

    private UUID id;
    private UUID patientId;
    private UUID doctorId;
    private String diagnosis;
    private String notes;
    private LocalDate visitDate;
    private Instant createdAt;
}
