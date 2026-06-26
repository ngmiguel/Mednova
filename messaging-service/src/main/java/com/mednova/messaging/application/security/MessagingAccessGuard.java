package com.mednova.messaging.application.security;

import com.mednova.common.exception.ForbiddenException;
import com.mednova.messaging.infrastructure.persistence.entity.ConversationEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class MessagingAccessGuard {

    public GatewayUserAuthentication currentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        throw new ForbiddenException("Utilisateur non authentifié");
    }

    public void checkCanList() {
        var user = currentUser();
        if (isAdminOrNurse(user) || user.hasRole("ROLE_PATIENT") || user.hasRole("ROLE_DOCTOR")) {
            return;
        }
        throw new ForbiddenException("Accès refusé aux conversations");
    }

    public void checkCanRead(ConversationEntity conversation) {
        var user = currentUser();
        if (isAdminOrNurse(user)) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT") && user.getUserId().equals(conversation.getPatientUserId())) {
            return;
        }
        if (user.hasRole("ROLE_DOCTOR") && user.getUserId().equals(conversation.getDoctorUserId())) {
            return;
        }
        throw new ForbiddenException("Accès refusé à cette conversation");
    }

    public void checkCanCreate(UUID patientUserId, UUID doctorUserId) {
        var user = currentUser();
        if (isAdminOrNurse(user)) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT") && user.getUserId().equals(patientUserId)) {
            return;
        }
        if (user.hasRole("ROLE_DOCTOR") && user.getUserId().equals(doctorUserId)) {
            return;
        }
        throw new ForbiddenException("Accès refusé pour créer cette conversation");
    }

    public boolean isAdminOrNurse() {
        return isAdminOrNurse(currentUser());
    }

    private boolean isAdminOrNurse(GatewayUserAuthentication user) {
        return user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_NURSE");
    }
}
