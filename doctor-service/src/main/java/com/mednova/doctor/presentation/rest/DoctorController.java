package com.mednova.doctor.presentation.rest;

import com.mednova.common.dto.ApiResponse;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.util.CorrelationIdUtils;
import com.mednova.doctor.application.service.DoctorApplicationService;
import com.mednova.doctor.domain.model.Specialty;
import com.mednova.doctor.presentation.dto.CreateDoctorRequest;
import com.mednova.doctor.presentation.dto.DoctorResponse;
import com.mednova.doctor.presentation.dto.UpdateDoctorRequest;
import com.mednova.doctor.presentation.mapper.DoctorMapper;
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
@RequestMapping("/api/v1/doctors")
@RequiredArgsConstructor
@Tag(name = "Médecins", description = "Gestion des profils médecins et spécialités")
@SecurityRequirement(name = "bearerAuth")
public class DoctorController {

    private final DoctorApplicationService doctorApplicationService;
    private final DoctorMapper doctorMapper;

    @PostMapping
    @Operation(summary = "Créer un profil médecin (ADMIN)")
    public ResponseEntity<ApiResponse<DoctorResponse>> create(
            @Valid @RequestBody CreateDoctorRequest request,
            HttpServletRequest httpRequest
    ) {
        var doctor = doctorApplicationService.create(doctorMapper.toDomain(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success("Médecin créé", doctorMapper.toResponse(doctor), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping
    @Operation(summary = "Lister les médecins (filtrable par spécialité)")
    public ResponseEntity<ApiResponse<PageResponse<DoctorResponse>>> list(
            @RequestParam(required = false) Specialty specialty,
            @PageableDefault(size = 20) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = doctorApplicationService.list(specialty, pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(doctorMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un médecin par ID")
    public ResponseEntity<ApiResponse<DoctorResponse>> getById(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var doctor = doctorApplicationService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(doctorMapper.toResponse(doctor), CorrelationIdUtils.resolve(httpRequest)));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un profil médecin")
    public ResponseEntity<ApiResponse<DoctorResponse>> update(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateDoctorRequest request,
            HttpServletRequest httpRequest
    ) {
        var doctor = doctorApplicationService.update(id, doctorMapper.toDomain(request));
        return ResponseEntity.ok(
                ApiResponse.success("Médecin mis à jour", doctorMapper.toResponse(doctor), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un profil médecin (ADMIN)")
    public ResponseEntity<ApiResponse<Void>> delete(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        doctorApplicationService.delete(id);
        return ResponseEntity.ok(
                ApiResponse.success("Médecin supprimé", null, CorrelationIdUtils.resolve(httpRequest))
        );
    }
}
