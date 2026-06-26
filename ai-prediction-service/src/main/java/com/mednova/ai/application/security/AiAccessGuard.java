package com.mednova.ai.application.security;

import com.mednova.ai.domain.model.RiskAssessment;
import com.mednova.common.exception.ForbiddenException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class AiAccessGuard {

    public GatewayUserAuthentication currentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        throw new ForbiddenException("Utilisateur non authentifié");
    }

    public void checkCanRead(RiskAssessment assessment) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT")
                && assessment.getPatientUserId() != null
                && assessment.getPatientUserId().equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Accès refusé à cette évaluation de risque");
    }

    public void checkCanListPatient(UUID patientId) {
        if (isStaff()) {
            return;
        }
        if (isPatient()) {
            return;
        }
        throw new ForbiddenException("Accès refusé aux évaluations de risque");
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
