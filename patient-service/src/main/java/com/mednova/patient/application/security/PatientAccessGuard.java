package com.mednova.patient.application.security;

import com.mednova.common.exception.ForbiddenException;
import com.mednova.patient.domain.model.Patient;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class PatientAccessGuard {

    public GatewayUserAuthentication currentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        throw new ForbiddenException("Utilisateur non authentifié");
    }

    public void checkCanRead(Patient patient) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT") && patient.getUserId() != null && patient.getUserId().equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Accès refusé à ce dossier patient");
    }

    public void checkCanList() {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        throw new ForbiddenException("Vous n'avez pas les droits pour consulter la liste des patients");
    }

    public void checkCanWrite() {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR") || user.hasRole("ROLE_NURSE")) {
            return;
        }
        throw new ForbiddenException("Vous n'avez pas les droits pour modifier un dossier patient");
    }

    public void checkCanDelete() {
        if (!currentUser().hasRole("ROLE_ADMIN")) {
            throw new ForbiddenException("Seul un administrateur peut supprimer un dossier patient");
        }
    }

    public UUID currentUserId() {
        return currentUser().getUserId();
    }
}
