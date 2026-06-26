package com.mednova.notification.application.security;

import com.mednova.common.exception.ForbiddenException;
import com.mednova.notification.domain.model.Notification;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class NotificationAccessGuard {

    public GatewayUserAuthentication currentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        throw new ForbiddenException("Utilisateur non authentifié");
    }

    public void checkCanRead(Notification notification) {
        var user = currentUser();
        if (isStaff(user)) {
            if ("STAFF".equals(notification.getTargetRole()) || notification.getTargetRole() == null) {
                return;
            }
        }
        if (user.hasRole("ROLE_PATIENT") && "ROLE_PATIENT".equals(notification.getTargetRole())) {
            return;
        }
        throw new ForbiddenException("Accès refusé à cette notification");
    }

    public void checkCanList() {
        var user = currentUser();
        if (isStaff(user) || user.hasRole("ROLE_PATIENT")) {
            return;
        }
        throw new ForbiddenException("Accès refusé aux notifications");
    }

    public boolean isStaff() {
        return isStaff(currentUser());
    }

    public boolean isPatient() {
        return currentUser().hasRole("ROLE_PATIENT");
    }

    private boolean isStaff(GatewayUserAuthentication user) {
        return user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_DOCTOR")
                || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR");
    }
}
