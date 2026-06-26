package com.mednova.doctor.infrastructure.security;

import com.mednova.common.constant.HttpHeaders;
import com.mednova.doctor.application.security.GatewayUserAuthentication;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;

@Component
public class GatewayHeaderAuthenticationFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String userIdHeader = request.getHeader(HttpHeaders.USER_ID);
        String rolesHeader = request.getHeader(HttpHeaders.USER_ROLES);

        if (userIdHeader != null && !userIdHeader.isBlank() && rolesHeader != null) {
            var authentication = GatewayUserAuthentication.fromHeaders(UUID.fromString(userIdHeader), rolesHeader);
            org.springframework.security.core.context.SecurityContextHolder.getContext()
                    .setAuthentication(authentication);
        }

        filterChain.doFilter(request, response);
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return path.startsWith("/actuator") || path.startsWith("/v3/api-docs") || path.startsWith("/swagger-ui");
    }
}
