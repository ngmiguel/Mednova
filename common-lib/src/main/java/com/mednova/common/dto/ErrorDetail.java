package com.mednova.common.dto;

public record ErrorDetail(
        String field,
        String message,
        Object rejectedValue
) {
    public static ErrorDetail of(String field, String message) {
        return new ErrorDetail(field, message, null);
    }

    public static ErrorDetail of(String field, String message, Object rejectedValue) {
        return new ErrorDetail(field, message, rejectedValue);
    }
}
