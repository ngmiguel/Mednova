package com.mednova.patient.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class Patient {

    private UUID id;
    private UUID userId;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private LocalDate dateOfBirth;
    private BloodType bloodType;
    private String gender;
    private String address;
    private String emergencyContact;
    private Instant createdAt;
    private Instant updatedAt;
}
