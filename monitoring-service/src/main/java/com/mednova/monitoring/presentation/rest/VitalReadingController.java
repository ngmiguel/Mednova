package com.mednova.monitoring.presentation.rest;

import com.mednova.common.dto.ApiResponse;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.util.CorrelationIdUtils;
import com.mednova.monitoring.application.service.VitalReadingApplicationService;
import com.mednova.monitoring.presentation.dto.CreateVitalReadingRequest;
import com.mednova.monitoring.presentation.dto.VitalReadingResponse;
import com.mednova.monitoring.presentation.mapper.VitalReadingMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/monitoring")
@RequiredArgsConstructor
@Tag(name = "Monitoring", description = "Constantes vitales et alertes temps réel")
@SecurityRequirement(name = "bearerAuth")
public class VitalReadingController {

    private final VitalReadingApplicationService vitalReadingApplicationService;
    private final VitalReadingMapper vitalReadingMapper;

    @PostMapping("/vitals")
    @Operation(summary = "Enregistrer des constantes vitales (personnel médical)")
    public ResponseEntity<ApiResponse<VitalReadingResponse>> record(
            @Valid @RequestBody CreateVitalReadingRequest request,
            HttpServletRequest httpRequest
    ) {
        var reading = vitalReadingApplicationService.record(vitalReadingMapper.toDomain(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success("Constantes vitales enregistrées", vitalReadingMapper.toResponse(reading), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping("/vitals/{id}")
    @Operation(summary = "Obtenir une mesure par ID")
    public ResponseEntity<ApiResponse<VitalReadingResponse>> getById(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var reading = vitalReadingApplicationService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(vitalReadingMapper.toResponse(reading), CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/patients/{patientId}/vitals")
    @Operation(summary = "Historique des constantes vitales d'un patient")
    public ResponseEntity<ApiResponse<PageResponse<VitalReadingResponse>>> listByPatient(
            @PathVariable UUID patientId,
            @RequestParam(required = false) UUID patientUserId,
            @PageableDefault(size = 20) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = vitalReadingApplicationService.listByPatient(patientId, patientUserId, pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(vitalReadingMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/patients/{patientId}/vitals/latest")
    @Operation(summary = "Dernière mesure d'un patient")
    public ResponseEntity<ApiResponse<VitalReadingResponse>> getLatest(
            @PathVariable UUID patientId,
            HttpServletRequest httpRequest
    ) {
        var reading = vitalReadingApplicationService.getLatestByPatientId(patientId);
        return ResponseEntity.ok(ApiResponse.success(vitalReadingMapper.toResponse(reading), CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/alerts")
    @Operation(summary = "Lister les mesures avec anomalies détectées")
    public ResponseEntity<ApiResponse<PageResponse<VitalReadingResponse>>> listAnomalies(
            @PageableDefault(size = 20) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = vitalReadingApplicationService.listAnomalies(pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(vitalReadingMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest)));
    }
}
