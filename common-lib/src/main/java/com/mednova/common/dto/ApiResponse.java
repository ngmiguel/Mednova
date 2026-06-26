package com.mednova.common.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(
        boolean success,
        String message,
        T data,
        Instant timestamp,
        String correlationId
) {

    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, null, data, Instant.now(), null);
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(true, message, data, Instant.now(), null);
    }

    public static <T> ApiResponse<T> success(String message, T data, String correlationId) {
        return new ApiResponse<>(true, message, data, Instant.now(), correlationId);
    }

    public static <T> ApiResponse<T> success(T data, String correlationId) {
        return new ApiResponse<>(true, null, data, Instant.now(), correlationId);
    }

    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, message, null, Instant.now(), null);
    }

    public static <T> ApiResponse<T> error(String message, String correlationId) {
        return new ApiResponse<>(false, message, null, Instant.now(), correlationId);
    }
}
