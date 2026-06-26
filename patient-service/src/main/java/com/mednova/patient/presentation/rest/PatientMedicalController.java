package com.mednova.patient.presentation.rest;

import com.mednova.common.dto.ApiResponse;
import com.mednova.common.util.CorrelationIdUtils;
import com.mednova.patient.application.service.AllergyApplicationService;
import com.mednova.patient.application.service.MedicalRecordApplicationService;
import com.mednova.patient.application.service.TreatmentApplicationService;
import com.mednova.patient.presentation.dto.*;
import com.mednova.patient.presentation.mapper.PatientMapper;
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
@RequestMapping("/api/v1/patients/{patientId}")
@RequiredArgsConstructor
@Tag(name = "Dossier médical", description = "Historique médical, traitements et allergies")
@SecurityRequirement(name = "bearerAuth")
public class PatientMedicalController {

    private final MedicalRecordApplicationService medicalRecordApplicationService;
    private final TreatmentApplicationService treatmentApplicationService;
    private final AllergyApplicationService allergyApplicationService;
    private final PatientMapper patientMapper;

    @GetMapping("/medical-records")
    @Operation(summary = "Lister les dossiers médicaux d'un patient")
    public ResponseEntity<ApiResponse<List<MedicalRecordResponse>>> listRecords(
            @PathVariable UUID patientId,
            HttpServletRequest httpRequest
    ) {
        var records = medicalRecordApplicationService.listByPatient(patientId).stream()
                .map(patientMapper::toResponse).toList();
        return ResponseEntity.ok(ApiResponse.success(records, CorrelationIdUtils.resolve(httpRequest)));
    }

    @PostMapping("/medical-records")
    @Operation(summary = "Ajouter un dossier médical")
    public ResponseEntity<ApiResponse<MedicalRecordResponse>> createRecord(
            @PathVariable UUID patientId,
            @Valid @RequestBody CreateMedicalRecordRequest request,
            HttpServletRequest httpRequest
    ) {
        var record = medicalRecordApplicationService.create(patientId, patientMapper.toDomain(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success("Dossier médical ajouté", patientMapper.toResponse(record), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping("/medical-records/{recordId}")
    @Operation(summary = "Obtenir un dossier médical")
    public ResponseEntity<ApiResponse<MedicalRecordResponse>> getRecord(
            @PathVariable UUID patientId,
            @PathVariable UUID recordId,
            HttpServletRequest httpRequest
    ) {
        var record = medicalRecordApplicationService.getById(patientId, recordId);
        return ResponseEntity.ok(ApiResponse.success(patientMapper.toResponse(record), CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/treatments")
    @Operation(summary = "Lister les traitements d'un patient")
    public ResponseEntity<ApiResponse<List<TreatmentResponse>>> listTreatments(
            @PathVariable UUID patientId,
            HttpServletRequest httpRequest
    ) {
        var treatments = treatmentApplicationService.listByPatient(patientId).stream()
                .map(patientMapper::toResponse).toList();
        return ResponseEntity.ok(ApiResponse.success(treatments, CorrelationIdUtils.resolve(httpRequest)));
    }

    @PostMapping("/treatments")
    @Operation(summary = "Ajouter un traitement")
    public ResponseEntity<ApiResponse<TreatmentResponse>> createTreatment(
            @PathVariable UUID patientId,
            @Valid @RequestBody CreateTreatmentRequest request,
            HttpServletRequest httpRequest
    ) {
        var treatment = treatmentApplicationService.create(patientId, patientMapper.toDomain(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success("Traitement ajouté", patientMapper.toResponse(treatment), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping("/allergies")
    @Operation(summary = "Lister les allergies d'un patient")
    public ResponseEntity<ApiResponse<List<AllergyResponse>>> listAllergies(
            @PathVariable UUID patientId,
            HttpServletRequest httpRequest
    ) {
        var allergies = allergyApplicationService.listByPatient(patientId).stream()
                .map(patientMapper::toResponse).toList();
        return ResponseEntity.ok(ApiResponse.success(allergies, CorrelationIdUtils.resolve(httpRequest)));
    }

    @PostMapping("/allergies")
    @Operation(summary = "Ajouter une allergie")
    public ResponseEntity<ApiResponse<AllergyResponse>> createAllergy(
            @PathVariable UUID patientId,
            @Valid @RequestBody CreateAllergyRequest request,
            HttpServletRequest httpRequest
    ) {
        var allergy = allergyApplicationService.create(patientId, patientMapper.toDomain(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success("Allergie ajoutée", patientMapper.toResponse(allergy), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @DeleteMapping("/allergies/{allergyId}")
    @Operation(summary = "Supprimer une allergie")
    public ResponseEntity<ApiResponse<Void>> deleteAllergy(
            @PathVariable UUID patientId,
            @PathVariable UUID allergyId,
            HttpServletRequest httpRequest
    ) {
        allergyApplicationService.delete(patientId, allergyId);
        return ResponseEntity.ok(
                ApiResponse.success("Allergie supprimée", null, CorrelationIdUtils.resolve(httpRequest))
        );
    }
}
