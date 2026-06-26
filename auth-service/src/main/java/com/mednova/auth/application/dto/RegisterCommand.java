package com.mednova.auth.application.dto;

import com.mednova.auth.domain.model.RoleType;

public record RegisterCommand(
        String email,
        String password,
        String firstName,
        String lastName,
        RoleType role
) {
}
