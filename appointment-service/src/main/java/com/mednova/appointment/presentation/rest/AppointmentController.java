package com.mednova.appointment.presentation.rest;

import com.mednova.appointment.application.service.AppointmentApplicationService;
import com.mednova.appointment.domain.model.AppointmentStatus;
import com.mednova.appointment.presentation.dto.AppointmentResponse;
import com.mednova.appointment.presentation.dto.CreateAppointmentRequest;
import com.mednova.appointment.presentation.dto.UpdateAppointmentRequest;
import com.mednova.appointment.presentation.mapper.AppointmentMapper;
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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/appointments")
@RequiredArgsConstructor
@Tag(name = "Rendez-vous", description = "Planification et gestion des rendez-vous")
@SecurityRequirement(name = "bearerAuth")
public class AppointmentController {

    private final AppointmentApplicationService appointmentApplicationService;
    private final AppointmentMapper appointmentMapper;

    @PostMapping
    @Operation(summary = "Planifier un rendez-vous")
    public ResponseEntity<ApiResponse<AppointmentResponse>> create(
            @Valid @RequestBody CreateAppointmentRequest request,
            HttpServletRequest httpRequest
    ) {
        var appointment = appointmentApplicationService.create(appointmentMapper.toDomain(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(
                ApiResponse.success("Rendez-vous planifié", appointmentMapper.toResponse(appointment), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping
    @Operation(summary = "Lister les rendez-vous (filtres optionnels pour le staff)")
    public ResponseEntity<ApiResponse<PageResponse<AppointmentResponse>>> list(
            @RequestParam(required = false) UUID patientId,
            @RequestParam(required = false) UUID doctorId,
            @RequestParam(required = false) AppointmentStatus status,
            @PageableDefault(size = 20) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = appointmentApplicationService.list(patientId, doctorId, status, pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(appointmentMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un rendez-vous par ID")
    public ResponseEntity<ApiResponse<AppointmentResponse>> getById(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var appointment = appointmentApplicationService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(appointmentMapper.toResponse(appointment), CorrelationIdUtils.resolve(httpRequest)));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Modifier un rendez-vous (date, motif, notes)")
    public ResponseEntity<ApiResponse<AppointmentResponse>> update(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateAppointmentRequest request,
            HttpServletRequest httpRequest
    ) {
        var appointment = appointmentApplicationService.update(id, appointmentMapper.toDomain(request));
        return ResponseEntity.ok(
                ApiResponse.success("Rendez-vous mis à jour", appointmentMapper.toResponse(appointment), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PatchMapping("/{id}/cancel")
    @Operation(summary = "Annuler un rendez-vous")
    public ResponseEntity<ApiResponse<AppointmentResponse>> cancel(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var appointment = appointmentApplicationService.cancel(id);
        return ResponseEntity.ok(
                ApiResponse.success("Rendez-vous annulé", appointmentMapper.toResponse(appointment), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PatchMapping("/{id}/confirm")
    @Operation(summary = "Confirmer un rendez-vous (médecin / staff)")
    public ResponseEntity<ApiResponse<AppointmentResponse>> confirm(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var appointment = appointmentApplicationService.confirm(id);
        return ResponseEntity.ok(
                ApiResponse.success("Rendez-vous confirmé", appointmentMapper.toResponse(appointment), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un rendez-vous (ADMIN)")
    public ResponseEntity<ApiResponse<Void>> delete(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        appointmentApplicationService.delete(id);
        return ResponseEntity.ok(
                ApiResponse.success("Rendez-vous supprimé", null, CorrelationIdUtils.resolve(httpRequest))
        );
    }
}
