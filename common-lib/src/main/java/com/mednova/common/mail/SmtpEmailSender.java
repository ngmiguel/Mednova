package com.mednova.common.mail;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

@RequiredArgsConstructor
@Slf4j
public class SmtpEmailSender implements EmailSenderPort {

    private final JavaMailSender mailSender;
    private final MailProperties mailProperties;

    @Override
    public void send(String to, String subject, String textBody) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(mailProperties.getFrom());
        message.setTo(to);
        message.setSubject(subject);
        message.setText(textBody);
        mailSender.send(message);
        log.info("Email envoyé → {} | {}", to, subject);
    }
}
