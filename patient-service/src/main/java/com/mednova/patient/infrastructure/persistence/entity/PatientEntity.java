package com.mednova.patient.infrastructure.persistence.entity;

import com.mednova.patient.domain.model.BloodType;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "patients")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatientEntity {

    @Id
    private UUID id;

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "first_name", nullable = false)
    private String firstName;

    @Column(name = "last_name", nullable = false)
    private String lastName;

    private String email;
    private String phone;

    @Column(name = "date_of_birth", nullable = false)
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(name = "blood_type")
    private BloodType bloodType;

    private String gender;
    private String address;

    @Column(name = "emergency_contact")
    private String emergencyContact;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
