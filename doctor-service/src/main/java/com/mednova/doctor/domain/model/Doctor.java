package com.mednova.doctor.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class Doctor {

    private UUID id;
    private UUID userId;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private Specialty specialty;
    private String licenseNumber;
    private String bio;
    private boolean active;
    private Instant createdAt;
    private Instant updatedAt;
}
