package com.mednova.doctor.application.security;

import com.mednova.common.exception.ForbiddenException;
import com.mednova.doctor.domain.model.Doctor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class DoctorAccessGuard {

    public GatewayUserAuthentication currentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        throw new ForbiddenException("Utilisateur non authentifié");
    }

    public void checkCanRead() {
        currentUser();
    }

    public void checkCanCreate() {
        if (!currentUser().hasRole("ROLE_ADMIN")) {
            throw new ForbiddenException("Seul un administrateur peut créer un profil médecin");
        }
    }

    public void checkCanUpdate(Doctor doctor) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN")) {
            return;
        }
        if (user.hasRole("ROLE_DOCTOR") && doctor.getUserId() != null && doctor.getUserId().equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Vous n'avez pas les droits pour modifier ce profil médecin");
    }

    public void checkCanDelete() {
        if (!currentUser().hasRole("ROLE_ADMIN")) {
            throw new ForbiddenException("Seul un administrateur peut supprimer un profil médecin");
        }
    }

    public void checkCanManageAvailability(Doctor doctor) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_NURSE")) {
            return;
        }
        if (user.hasRole("ROLE_DOCTOR") && doctor.getUserId() != null && doctor.getUserId().equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Vous n'avez pas les droits pour gérer ce planning");
    }

    public UUID currentUserId() {
        return currentUser().getUserId();
    }
}
