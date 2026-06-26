package com.mednova.common.util;

import com.mednova.common.constant.HttpHeaders;
import jakarta.servlet.http.HttpServletRequest;

import java.util.UUID;

public final class CorrelationIdUtils {

    private CorrelationIdUtils() {
    }

    public static String resolve(HttpServletRequest request) {
        String correlationId = request.getHeader(HttpHeaders.CORRELATION_ID);
        if (correlationId == null || correlationId.isBlank()) {
            correlationId = UUID.randomUUID().toString();
        }
        return correlationId;
    }
}
