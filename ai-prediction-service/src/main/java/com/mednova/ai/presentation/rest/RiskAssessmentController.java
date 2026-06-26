package com.mednova.ai.presentation.rest;

import com.mednova.ai.application.service.RiskQueryService;
import com.mednova.ai.presentation.dto.RiskAssessmentResponse;
import com.mednova.ai.presentation.mapper.RiskAssessmentMapper;
import com.mednova.common.dto.ApiResponse;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.util.CorrelationIdUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
@Tag(name = "AI Prediction", description = "Health Risk Engine — scores et alertes prédictives")
@SecurityRequirement(name = "bearerAuth")
public class RiskAssessmentController {

    private final RiskQueryService riskQueryService;
    private final RiskAssessmentMapper riskAssessmentMapper;

    @GetMapping("/risk-assessments/{id}")
    @Operation(summary = "Obtenir une évaluation de risque par ID")
    public ResponseEntity<ApiResponse<RiskAssessmentResponse>> getById(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var assessment = riskQueryService.getById(id);
        return ResponseEntity.ok(
                ApiResponse.success(riskAssessmentMapper.toResponse(assessment), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping("/patients/{patientId}/risk-assessments")
    @Operation(summary = "Historique des évaluations de risque d'un patient")
    public ResponseEntity<ApiResponse<PageResponse<RiskAssessmentResponse>>> listByPatient(
            @PathVariable UUID patientId,
            @PageableDefault(size = 20) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = riskQueryService.listByPatient(patientId, pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(riskAssessmentMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/patients/{patientId}/risk-assessments/latest")
    @Operation(summary = "Dernière évaluation de risque d'un patient")
    public ResponseEntity<ApiResponse<RiskAssessmentResponse>> getLatest(
            @PathVariable UUID patientId,
            HttpServletRequest httpRequest
    ) {
        var assessment = riskQueryService.getLatestByPatientId(patientId);
        return ResponseEntity.ok(
                ApiResponse.success(riskAssessmentMapper.toResponse(assessment), CorrelationIdUtils.resolve(httpRequest))
        );
    }
}
