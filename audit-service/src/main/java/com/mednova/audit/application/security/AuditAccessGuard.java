package com.mednova.audit.application.security;

import com.mednova.common.exception.ForbiddenException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class AuditAccessGuard {

    public GatewayUserAuthentication currentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        throw new ForbiddenException("Utilisateur non authentifié");
    }

    public void checkCanRead() {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        throw new ForbiddenException("Seuls les administrateurs et auditeurs peuvent consulter le journal d'audit");
    }
}
