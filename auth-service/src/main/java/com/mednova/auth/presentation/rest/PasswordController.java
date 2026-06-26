package com.mednova.auth.presentation.rest;

import com.mednova.auth.application.service.PasswordResetApplicationService;
import com.mednova.auth.presentation.dto.ForgotPasswordRequest;
import com.mednova.auth.presentation.dto.PasswordResetTokenResponse;
import com.mednova.auth.presentation.dto.ResetPasswordRequest;
import com.mednova.auth.presentation.dto.VerifyPasswordOtpRequest;
import com.mednova.auth.presentation.mapper.AuthMapper;
import com.mednova.common.dto.ApiResponse;
import com.mednova.common.util.CorrelationIdUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth/password")
@RequiredArgsConstructor
@Tag(name = "Mot de passe", description = "Réinitialisation par OTP email (base pour mot de passe oublié)")
public class PasswordController {

    private final PasswordResetApplicationService passwordResetApplicationService;
    private final AuthMapper authMapper;

    @PostMapping("/forgot")
    @Operation(summary = "Demander un code OTP par email (simulé)")
    public ResponseEntity<ApiResponse<Void>> forgot(
            @Valid @RequestBody ForgotPasswordRequest request,
            HttpServletRequest httpRequest
    ) {
        passwordResetApplicationService.requestReset(request.email());
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Si le compte existe, un code de vérification a été envoyé par email",
                        null,
                        CorrelationIdUtils.resolve(httpRequest)
        ));
    }

    @PostMapping("/verify-otp")
    @Operation(summary = "Vérifier le code OTP et obtenir un jeton de réinitialisation")
    public ResponseEntity<ApiResponse<PasswordResetTokenResponse>> verifyOtp(
            @Valid @RequestBody VerifyPasswordOtpRequest request,
            HttpServletRequest httpRequest
    ) {
        var result = passwordResetApplicationService.verifyOtp(request.email(), request.otp());
        return ResponseEntity.ok(
                ApiResponse.success(
                        authMapper.toResetTokenResponse(result),
                        CorrelationIdUtils.resolve(httpRequest)
                )
        );
    }

    @PostMapping("/reset")
    @Operation(summary = "Réinitialiser le mot de passe avec le jeton obtenu")
    public ResponseEntity<ApiResponse<Void>> reset(
            @Valid @RequestBody ResetPasswordRequest request,
            HttpServletRequest httpRequest
    ) {
        passwordResetApplicationService.resetPassword(request.resetToken(), request.newPassword());
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Mot de passe réinitialisé avec succès",
                        null,
                        CorrelationIdUtils.resolve(httpRequest)
                )
        );
    }
}
