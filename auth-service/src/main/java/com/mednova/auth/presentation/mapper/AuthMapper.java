package com.mednova.auth.presentation.mapper;

import com.mednova.auth.application.dto.AuthTokens;
import com.mednova.auth.application.dto.LoginCommand;
import com.mednova.auth.application.dto.PasswordOtpVerificationResult;
import com.mednova.auth.application.dto.RegisterCommand;
import com.mednova.auth.application.dto.TwoFactorSetupResult;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.presentation.dto.AuthResponse;
import com.mednova.auth.presentation.dto.LoginRequest;
import com.mednova.auth.presentation.dto.PasswordResetTokenResponse;
import com.mednova.auth.presentation.dto.RegisterRequest;
import com.mednova.auth.presentation.dto.TwoFactorSetupResponse;
import com.mednova.auth.presentation.dto.UserResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AuthMapper {

    RegisterCommand toCommand(RegisterRequest request);

    LoginCommand toCommand(LoginRequest request);

    AuthResponse toResponse(AuthTokens tokens);

    @Mapping(target = "twoFactorEnabled", source = "twoFactorEnabled")
    UserResponse toResponse(User user);

    TwoFactorSetupResponse toSetupResponse(TwoFactorSetupResult result);

    PasswordResetTokenResponse toResetTokenResponse(PasswordOtpVerificationResult result);
}
