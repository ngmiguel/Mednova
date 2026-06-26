package com.mednova.common.exception;

import org.springframework.http.HttpStatus;

public class BusinessException extends BaseException {

    public BusinessException(String message) {
        super(message, ErrorCode.BUSINESS_ERROR, HttpStatus.UNPROCESSABLE_ENTITY);
    }
}
