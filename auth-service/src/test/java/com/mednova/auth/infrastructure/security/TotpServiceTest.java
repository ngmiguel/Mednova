package com.mednova.auth.infrastructure.security;

import dev.samstevens.totp.code.DefaultCodeGenerator;
import dev.samstevens.totp.exceptions.CodeGenerationException;
import dev.samstevens.totp.time.SystemTimeProvider;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class TotpServiceTest {

    private final TotpService totpService = new TotpService();
    private final DefaultCodeGenerator codeGenerator = new DefaultCodeGenerator();
    private final SystemTimeProvider timeProvider = new SystemTimeProvider();

    @Test
    void generateSecret_returnsNonBlankSecret() {
        assertThat(totpService.generateSecret()).isNotBlank();
    }

    @Test
    void verifyCode_acceptsValidCode() throws CodeGenerationException {
        String secret = totpService.generateSecret();
        long counter = Math.floorDiv(timeProvider.getTime(), 30);
        String code = codeGenerator.generate(secret, counter);
        assertThat(totpService.verifyCode(secret, code)).isTrue();
    }

    @Test
    void verifyCode_rejectsInvalidCode() {
        String secret = totpService.generateSecret();
        assertThat(totpService.verifyCode(secret, "000000")).isFalse();
    }

    @Test
    void buildOtpAuthUrl_containsIssuerAndEmail() {
        String url = totpService.buildOtpAuthUrl("user@mednova.ai", totpService.generateSecret());
        assertThat(url).contains("MedNova%20AI").contains("user%40mednova.ai");
    }
}
