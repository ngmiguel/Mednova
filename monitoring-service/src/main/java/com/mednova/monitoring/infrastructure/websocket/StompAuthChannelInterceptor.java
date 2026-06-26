package com.mednova.monitoring.infrastructure.websocket;

import com.mednova.monitoring.application.security.GatewayUserAuthentication;
import com.mednova.monitoring.application.security.MonitoringAccessGuard;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@RequiredArgsConstructor
@Slf4j
public class StompAuthChannelInterceptor implements ChannelInterceptor {

    private static final Pattern PATIENT_TOPIC_PATTERN =
            Pattern.compile("^/topic/patients/([0-9a-fA-F-]{36})/vitals$");

    private final MonitoringAccessGuard accessGuard;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        if (accessor == null) {
            return message;
        }

        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            GatewayUserAuthentication user = extractUser(accessor.getSessionAttributes());
            if (user == null) {
                throw new IllegalStateException("Connexion WebSocket non authentifiée");
            }
            accessor.setUser(user);
            SecurityContextHolder.getContext().setAuthentication(user);
            return message;
        }

        if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            GatewayUserAuthentication user = resolveUser(accessor);
            SecurityContextHolder.getContext().setAuthentication(user);

            String destination = accessor.getDestination();
            if (destination != null && destination.startsWith("/topic/patients/")) {
                UUID patientId = extractPatientId(destination);
                accessGuard.checkCanSubscribeToPatient(patientId);
            } else if ("/topic/monitoring/alerts".equals(destination)) {
                accessGuard.checkCanListAnomalies();
            }
        }

        return message;
    }

    private GatewayUserAuthentication resolveUser(StompHeaderAccessor accessor) {
        if (accessor.getUser() instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        GatewayUserAuthentication user = extractUser(accessor.getSessionAttributes());
        if (user == null) {
            throw new IllegalStateException("Session WebSocket non authentifiée");
        }
        return user;
    }

    private GatewayUserAuthentication extractUser(Map<String, Object> sessionAttributes) {
        if (sessionAttributes == null) {
            return null;
        }
        Object value = sessionAttributes.get(GatewayHandshakeInterceptor.USER_AUTH_ATTR);
        if (value instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        return null;
    }

    private UUID extractPatientId(String destination) {
        Matcher matcher = PATIENT_TOPIC_PATTERN.matcher(destination);
        if (!matcher.matches()) {
            throw new IllegalArgumentException("Destination WebSocket invalide : " + destination);
        }
        return UUID.fromString(matcher.group(1));
    }
}
