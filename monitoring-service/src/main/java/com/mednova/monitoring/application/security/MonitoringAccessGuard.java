package com.mednova.monitoring.application.security;

import com.mednova.common.exception.ForbiddenException;
import com.mednova.monitoring.domain.model.VitalReading;
import com.mednova.monitoring.domain.port.VitalReadingRepository;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class MonitoringAccessGuard {

    private final VitalReadingRepository vitalReadingRepository;

    public MonitoringAccessGuard(VitalReadingRepository vitalReadingRepository) {
        this.vitalReadingRepository = vitalReadingRepository;
    }

    public GatewayUserAuthentication currentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        throw new ForbiddenException("Utilisateur non authentifié");
    }

    public void checkCanRecord() {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR") || user.hasRole("ROLE_NURSE")) {
            return;
        }
        throw new ForbiddenException("Seul le personnel médical peut enregistrer des constantes vitales");
    }

    public void checkCanRead(VitalReading reading) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT")
                && reading.getPatientUserId() != null
                && reading.getPatientUserId().equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Accès refusé à ces constantes vitales");
    }

    public void checkCanReadPatient(UUID patientId, UUID patientUserId) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT")
                && patientUserId != null
                && patientUserId.equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Accès refusé au monitoring de ce patient");
    }

    public void checkCanSubscribeToPatient(UUID patientId) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT")
                && vitalReadingRepository.existsByPatientIdAndPatientUserId(patientId, user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Accès refusé au flux temps réel de ce patient");
    }

    public void checkCanListAnomalies() {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        throw new ForbiddenException("Accès refusé aux alertes de monitoring");
    }

    public UUID currentUserId() {
        return currentUser().getUserId();
    }

    public boolean isStaff() {
        var user = currentUser();
        return user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR");
    }

    public boolean isPatient() {
        return currentUser().hasRole("ROLE_PATIENT");
    }
}
