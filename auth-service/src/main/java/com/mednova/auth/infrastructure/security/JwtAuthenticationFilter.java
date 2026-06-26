package com.mednova.auth.infrastructure.security;

import com.mednova.auth.application.port.out.JwtParserPort;
import com.mednova.auth.application.port.out.TokenBlacklistPort;
import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.domain.model.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtParserPort jwtParserPort;
    private final TokenBlacklistPort tokenBlacklistPort;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);

            jwtParserPort.extractJti(token)
                    .filter(jti -> !tokenBlacklistPort.isBlacklisted(jti))
                    .flatMap(jti -> jwtParserPort.extractAuthenticatedUser(token))
                    .ifPresent(this::authenticate);
        }

        filterChain.doFilter(request, response);
    }

    private void authenticate(User user) {
        var authorities = user.getRoles().stream()
                .map(RoleType::name)
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());

        var authentication = new UsernamePasswordAuthenticationToken(
                user.getId(),
                null,
                authorities
        );
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }
}
