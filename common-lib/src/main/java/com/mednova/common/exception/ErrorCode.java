package com.mednova.common.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    RESOURCE_NOT_FOUND("NOT_FOUND"),
    UNAUTHORIZED("UNAUTHORIZED"),
    FORBIDDEN("FORBIDDEN"),
    CONFLICT("CONFLICT"),
    VALIDATION_ERROR("VALIDATION_ERROR"),
    BUSINESS_ERROR("BUSINESS_ERROR"),
    INTERNAL_ERROR("INTERNAL_ERROR");

    private final String code;
}
