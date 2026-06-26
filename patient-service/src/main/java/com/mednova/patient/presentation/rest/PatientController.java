package com.mednova.patient.presentation.rest;

import com.mednova.common.dto.ApiResponse;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.util.CorrelationIdUtils;
import com.mednova.patient.application.service.PatientApplicationService;
import com.mednova.patient.presentation.dto.CreatePatientRequest;
import com.mednova.patient.presentation.dto.PatientResponse;
import com.mednova.patient.presentation.dto.UpdatePatientRequest;
import com.mednova.patient.presentation.mapper.PatientMapper;
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
@RequestMapping("/api/v1/patients")
@RequiredArgsConstructor
@Tag(name = "Patients", description = "Gestion des dossiers patients")
@SecurityRequirement(name = "bearerAuth")
public class PatientController {

    private final PatientApplicationService patientApplicationService;
    private final PatientMapper patientMapper;

    @PostMapping
    @Operation(summary = "Créer un dossier patient")
    public ResponseEntity<ApiResponse<PatientResponse>> create(
            @Valid @RequestBody CreatePatientRequest request,
            HttpServletRequest httpRequest
    ) {
        var patient = patientApplicationService.create(patientMapper.toDomain(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success("Patient créé", patientMapper.toResponse(patient), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping
    @Operation(summary = "Lister les patients (paginé)")
    public ResponseEntity<ApiResponse<PageResponse<PatientResponse>>> list(
            @PageableDefault(size = 20) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = patientApplicationService.list(pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(patientMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(
                ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un patient par ID")
    public ResponseEntity<ApiResponse<PatientResponse>> getById(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var patient = patientApplicationService.getById(id);
        return ResponseEntity.ok(
                ApiResponse.success(patientMapper.toResponse(patient), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un dossier patient")
    public ResponseEntity<ApiResponse<PatientResponse>> update(
            @PathVariable UUID id,
            @Valid @RequestBody UpdatePatientRequest request,
            HttpServletRequest httpRequest
    ) {
        var patient = patientApplicationService.update(id, patientMapper.toDomain(request));
        return ResponseEntity.ok(
                ApiResponse.success("Patient mis à jour", patientMapper.toResponse(patient), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un dossier patient (ADMIN uniquement)")
    public ResponseEntity<ApiResponse<Void>> delete(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        patientApplicationService.delete(id);
        return ResponseEntity.ok(
                ApiResponse.success("Patient supprimé", null, CorrelationIdUtils.resolve(httpRequest))
        );
    }
}
