package com.mednova.auth.presentation.rest;

import com.mednova.auth.application.service.AuthApplicationService;
import com.mednova.auth.presentation.dto.*;
import com.mednova.auth.presentation.mapper.AuthMapper;
import com.mednova.common.dto.ApiResponse;
import com.mednova.common.util.CorrelationIdUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentification", description = "Inscription, connexion JWT et gestion de session")
public class AuthController {

    private final AuthApplicationService authApplicationService;
    private final AuthMapper authMapper;

    @PostMapping("/register")
    @Operation(summary = "Inscrire un nouvel utilisateur")
    public ResponseEntity<ApiResponse<AuthResponse>> register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletRequest httpRequest
    ) {
        var tokens = authApplicationService.register(authMapper.toCommand(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success(
                        "Inscription réussie",
                        authMapper.toResponse(tokens),
                        CorrelationIdUtils.resolve(httpRequest)
                )
        );
    }

    @PostMapping("/login")
    @Operation(summary = "Se connecter et obtenir un JWT")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest
    ) {
        var tokens = authApplicationService.login(authMapper.toCommand(request));
        String message = tokens.requiresTwoFactor()
                ? "Code 2FA requis — utilisez /api/v1/auth/2fa/verify-login"
                : "Connexion réussie";
        return ResponseEntity.ok(
                ApiResponse.success(
                        message,
                        authMapper.toResponse(tokens),
                        CorrelationIdUtils.resolve(httpRequest)
                )
        );
    }

    @PostMapping("/refresh")
    @Operation(summary = "Rafraîchir le token d'accès")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(
            @Valid @RequestBody RefreshTokenRequest request,
            HttpServletRequest httpRequest
    ) {
        var tokens = authApplicationService.refresh(request.refreshToken());
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Token rafraîchi",
                        authMapper.toResponse(tokens),
                        CorrelationIdUtils.resolve(httpRequest)
                )
        );
    }

    @PostMapping("/logout")
    @Operation(summary = "Se déconnecter et révoquer les tokens")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestBody(required = false) LogoutRequest request,
            @RequestHeader("Authorization") String authorization,
            HttpServletRequest httpRequest
    ) {
        String refreshToken = request != null ? request.refreshToken() : null;
        authApplicationService.logout(authorization, refreshToken);
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Déconnexion réussie",
                        null,
                        CorrelationIdUtils.resolve(httpRequest)
                )
        );
    }

    @GetMapping("/me")
    @Operation(summary = "Obtenir le profil de l'utilisateur connecté")
    public ResponseEntity<ApiResponse<UserResponse>> me(
            @AuthenticationPrincipal UUID userId,
            HttpServletRequest httpRequest
    ) {
        var user = authApplicationService.getCurrentUser(userId);
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Profil récupéré",
                        authMapper.toResponse(user),
                        CorrelationIdUtils.resolve(httpRequest)
                )
        );
    }
}
