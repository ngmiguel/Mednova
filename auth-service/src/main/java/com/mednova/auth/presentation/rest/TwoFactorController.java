package com.mednova.auth.presentation.rest;

import com.mednova.auth.application.service.PasswordResetApplicationService;
import com.mednova.auth.application.service.TwoFactorApplicationService;
import com.mednova.auth.presentation.dto.*;
import com.mednova.auth.presentation.mapper.AuthMapper;
import com.mednova.common.dto.ApiResponse;
import com.mednova.common.util.CorrelationIdUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/auth/2fa")
@RequiredArgsConstructor
@Tag(name = "Authentification 2FA", description = "Double authentification TOTP (Google Authenticator)")
public class TwoFactorController {

    private final TwoFactorApplicationService twoFactorApplicationService;
    private final AuthMapper authMapper;

    @GetMapping("/status")
    @Operation(summary = "Statut 2FA de l'utilisateur connecté")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<TwoFactorStatusResponse>> status(
            @AuthenticationPrincipal UUID userId,
            HttpServletRequest httpRequest
    ) {
        boolean enabled = twoFactorApplicationService.isEnabled(userId);
        return ResponseEntity.ok(
                ApiResponse.success(new TwoFactorStatusResponse(enabled), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PostMapping("/setup")
    @Operation(summary = "Initialiser la 2FA — secret + QR code")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<TwoFactorSetupResponse>> setup(
            @AuthenticationPrincipal UUID userId,
            HttpServletRequest httpRequest
    ) {
        var result = twoFactorApplicationService.setup(userId);
        return ResponseEntity.ok(
                ApiResponse.success(authMapper.toSetupResponse(result), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PostMapping("/enable")
    @Operation(summary = "Activer la 2FA après vérification du code TOTP")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<Void>> enable(
            @AuthenticationPrincipal UUID userId,
            @Valid @RequestBody EnableTwoFactorRequest request,
            HttpServletRequest httpRequest
    ) {
        twoFactorApplicationService.enable(userId, request.code());
        return ResponseEntity.ok(
                ApiResponse.success("Double authentification activée", null, CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PostMapping("/disable")
    @Operation(summary = "Désactiver la 2FA (mot de passe + code TOTP)")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<Void>> disable(
            @AuthenticationPrincipal UUID userId,
            @Valid @RequestBody DisableTwoFactorRequest request,
            HttpServletRequest httpRequest
    ) {
        twoFactorApplicationService.disable(userId, request.code(), request.password());
        return ResponseEntity.ok(
                ApiResponse.success("Double authentification désactivée", null, CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PostMapping("/verify-login")
    @Operation(summary = "Compléter la connexion avec le code TOTP")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyLogin(
            @Valid @RequestBody VerifyTwoFactorLoginRequest request,
            HttpServletRequest httpRequest
    ) {
        var tokens = twoFactorApplicationService.verifyLogin(request.challengeToken(), request.code());
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Connexion réussie",
                        authMapper.toResponse(tokens),
                        CorrelationIdUtils.resolve(httpRequest)
                )
        );
    }
}
