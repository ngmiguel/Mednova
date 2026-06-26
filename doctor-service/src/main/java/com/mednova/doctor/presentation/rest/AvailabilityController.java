package com.mednova.doctor.presentation.rest;

import com.mednova.common.dto.ApiResponse;
import com.mednova.common.util.CorrelationIdUtils;
import com.mednova.doctor.application.service.AvailabilityApplicationService;
import com.mednova.doctor.presentation.dto.AvailabilityResponse;
import com.mednova.doctor.presentation.dto.CreateAvailabilityRequest;
import com.mednova.doctor.presentation.mapper.DoctorMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/doctors/{doctorId}/availabilities")
@RequiredArgsConstructor
@Tag(name = "Disponibilités", description = "Planning et créneaux des médecins")
@SecurityRequirement(name = "bearerAuth")
public class AvailabilityController {

    private final AvailabilityApplicationService availabilityApplicationService;
    private final DoctorMapper doctorMapper;

    @GetMapping
    @Operation(summary = "Lister les disponibilités d'un médecin")
    public ResponseEntity<ApiResponse<List<AvailabilityResponse>>> list(
            @PathVariable UUID doctorId,
            HttpServletRequest httpRequest
    ) {
        var availabilities = availabilityApplicationService.listByDoctor(doctorId).stream()
                .map(doctorMapper::toResponse)
                .toList();
        return ResponseEntity.ok(ApiResponse.success(availabilities, CorrelationIdUtils.resolve(httpRequest)));
    }

    @PostMapping
    @Operation(summary = "Ajouter un créneau de disponibilité")
    public ResponseEntity<ApiResponse<AvailabilityResponse>> create(
            @PathVariable UUID doctorId,
            @Valid @RequestBody CreateAvailabilityRequest request,
            HttpServletRequest httpRequest
    ) {
        var availability = availabilityApplicationService.create(doctorId, doctorMapper.toDomain(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success("Disponibilité ajoutée", doctorMapper.toResponse(availability), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @DeleteMapping("/{availabilityId}")
    @Operation(summary = "Supprimer un créneau de disponibilité")
    public ResponseEntity<ApiResponse<Void>> delete(
            @PathVariable UUID doctorId,
            @PathVariable UUID availabilityId,
            HttpServletRequest httpRequest
    ) {
        availabilityApplicationService.delete(doctorId, availabilityId);
        return ResponseEntity.ok(
                ApiResponse.success("Disponibilité supprimée", null, CorrelationIdUtils.resolve(httpRequest))
        );
    }
}
