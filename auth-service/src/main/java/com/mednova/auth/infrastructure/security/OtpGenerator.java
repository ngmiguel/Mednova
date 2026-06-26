package com.mednova.auth.infrastructure.security;

import com.mednova.auth.application.port.out.TokenProviderPort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;

@Component
@RequiredArgsConstructor
public class OtpGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final TokenProviderPort tokenProviderPort;

    public String generateSixDigitCode() {
        return String.format("%06d", RANDOM.nextInt(1_000_000));
    }

    public String hashCode(String code) {
        return tokenProviderPort.hashToken(code);
    }

    public boolean matches(String rawCode, String storedHash) {
        return hashCode(rawCode).equals(storedHash);
    }
}
