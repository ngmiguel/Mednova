package com.mednova.gateway.filter;

import com.mednova.common.constant.HttpHeaders;
import com.mednova.gateway.config.GatewayProperties;
import com.mednova.gateway.security.GatewayJwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.time.Instant;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter implements GlobalFilter, Ordered {

    private final GatewayProperties gatewayProperties;
    private final GatewayJwtService gatewayJwtService;
    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().value();

        if (isPublicPath(path)) {
            return chain.filter(exchange);
        }

        String authorization = exchange.getRequest().getHeaders().getFirst(org.springframework.http.HttpHeaders.AUTHORIZATION);
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            return unauthorized(exchange, "Token d'authentification manquant");
        }

        var claimsOpt = gatewayJwtService.parseToken(authorization);
        if (claimsOpt.isEmpty()) {
            return unauthorized(exchange, "Token invalide ou expiré");
        }

        var claims = claimsOpt.get();
        return gatewayJwtService.isBlacklisted(claims.jti())
                .flatMap(blacklisted -> {
                    if (Boolean.TRUE.equals(blacklisted)) {
                        return unauthorized(exchange, "Token révoqué");
                    }
                    ServerHttpRequest mutated = exchange.getRequest().mutate()
                            .header(HttpHeaders.USER_ID, claims.userId().toString())
                            .header(HttpHeaders.USER_ROLES, String.join(",", claims.roles()))
                            .build();
                    return chain.filter(exchange.mutate().request(mutated).build());
                });
    }

    private boolean isPublicPath(String path) {
        return gatewayProperties.getPublicPaths().stream()
                .anyMatch(pattern -> pathMatcher.match(pattern, path));
    }

    private Mono<Void> unauthorized(ServerWebExchange exchange, String message) {
        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
        exchange.getResponse().getHeaders().setContentType(MediaType.APPLICATION_JSON);

        String correlationId = exchange.getRequest().getHeaders().getFirst(HttpHeaders.CORRELATION_ID);
        String body = """
                {
                  "timestamp": "%s",
                  "status": 401,
                  "error": "UNAUTHORIZED",
                  "message": "%s",
                  "path": "%s",
                  "correlationId": "%s"
                }
                """.formatted(Instant.now(), message, exchange.getRequest().getPath().value(), correlationId);

        var buffer = exchange.getResponse().bufferFactory().wrap(body.getBytes(StandardCharsets.UTF_8));
        return exchange.getResponse().writeWith(Mono.just(buffer));
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE + 1;
    }
}
