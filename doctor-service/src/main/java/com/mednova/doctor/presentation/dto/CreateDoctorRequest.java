package com.mednova.doctor.presentation.dto;

import com.mednova.doctor.domain.model.Specialty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateDoctorRequest(
        UUID userId,
        @NotBlank String firstName,
        @NotBlank String lastName,
        @NotBlank @Email String email,
        String phone,
        @NotNull Specialty specialty,
        @NotBlank String licenseNumber,
        String bio
) {
}
