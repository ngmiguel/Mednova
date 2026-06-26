package com.mednova.monitoring.infrastructure.websocket;

import com.mednova.common.constant.HttpHeaders;
import com.mednova.monitoring.application.security.GatewayUserAuthentication;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;
import java.util.UUID;

@Component
@Slf4j
public class GatewayHandshakeInterceptor implements HandshakeInterceptor {

    public static final String USER_AUTH_ATTR = "gatewayUser";

    @Override
    public boolean beforeHandshake(
            ServerHttpRequest request,
            ServerHttpResponse response,
            WebSocketHandler wsHandler,
            Map<String, Object> attributes
    ) {
        String userIdHeader = request.getHeaders().getFirst(HttpHeaders.USER_ID);
        String rolesHeader = request.getHeaders().getFirst(HttpHeaders.USER_ROLES);

        if (userIdHeader != null && !userIdHeader.isBlank() && rolesHeader != null) {
            attributes.put(USER_AUTH_ATTR, GatewayUserAuthentication.fromHeaders(
                    UUID.fromString(userIdHeader), rolesHeader
            ));
            return true;
        }

        log.warn("WebSocket handshake without gateway identity headers");
        return false;
    }

    @Override
    public void afterHandshake(
            ServerHttpRequest request,
            ServerHttpResponse response,
            WebSocketHandler wsHandler,
            Exception exception
    ) {
        // no-op
    }
}
