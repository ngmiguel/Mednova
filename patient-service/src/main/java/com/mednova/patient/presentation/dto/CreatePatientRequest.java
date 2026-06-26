package com.mednova.patient.presentation.dto;

import com.mednova.patient.domain.model.BloodType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;

import java.time.LocalDate;
import java.util.UUID;

public record CreatePatientRequest(
        UUID userId,
        @NotBlank(message = "Le prénom est obligatoire") String firstName,
        @NotBlank(message = "Le nom est obligatoire") String lastName,
        @Email(message = "Format d'email invalide") String email,
        String phone,
        @NotNull(message = "La date de naissance est obligatoire")
        @Past(message = "La date de naissance doit être dans le passé") LocalDate dateOfBirth,
        BloodType bloodType,
        String gender,
        String address,
        String emergencyContact
) {
}
