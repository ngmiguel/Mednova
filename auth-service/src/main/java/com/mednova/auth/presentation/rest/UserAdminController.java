package com.mednova.auth.presentation.rest;

import com.mednova.auth.application.service.UserAdminApplicationService;
import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.presentation.dto.UpdateUserAccessRequest;
import com.mednova.auth.presentation.dto.UserResponse;
import com.mednova.auth.presentation.mapper.AuthMapper;
import com.mednova.common.dto.ApiResponse;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.util.CorrelationIdUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/auth/users")
@RequiredArgsConstructor
@PreAuthorize("hasAuthority('ROLE_ADMIN')")
@Tag(name = "Administration utilisateurs", description = "Gestion des comptes — ADMIN uniquement")
@SecurityRequirement(name = "bearerAuth")
public class UserAdminController {

    private final UserAdminApplicationService userAdminApplicationService;
    private final AuthMapper authMapper;

    @GetMapping
    @Operation(summary = "Lister les utilisateurs (filtrable par rôle)")
    public ResponseEntity<ApiResponse<PageResponse<UserResponse>>> list(
            @RequestParam(required = false) RoleType role,
            @PageableDefault(size = 50) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = userAdminApplicationService.list(role, pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(authMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un utilisateur par ID")
    public ResponseEntity<ApiResponse<UserResponse>> getById(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var user = userAdminApplicationService.getById(id);
        return ResponseEntity.ok(
                ApiResponse.success(authMapper.toResponse(user), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PatchMapping("/{id}/access")
    @Operation(summary = "Activer ou bloquer l'accès d'un compte")
    public ResponseEntity<ApiResponse<UserResponse>> updateAccess(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateUserAccessRequest request,
            @AuthenticationPrincipal UUID adminId,
            HttpServletRequest httpRequest
    ) {
        var user = userAdminApplicationService.updateAccess(id, request.enabled(), adminId);
        String message = request.enabled() ? "Accès réactivé" : "Accès bloqué";
        return ResponseEntity.ok(
                ApiResponse.success(message, authMapper.toResponse(user), CorrelationIdUtils.resolve(httpRequest))
        );
    }
}
