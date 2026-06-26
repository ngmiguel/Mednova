package com.mednova.auth.infrastructure.notification;

import com.mednova.common.mail.EmailSenderPort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class EmailOtpSender {

    private final EmailSenderPort emailSender;

    public void sendPasswordResetOtp(String email, String otp) {
        emailSender.send(
                email,
                "MedNova AI — Code de réinitialisation",
                """
                Bonjour,

                Votre code de vérification MedNova AI est : %s

                Ce code expire dans 10 minutes.
                Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.

                — MedNova AI
                """.formatted(otp)
        );
    }
}
