package com.mednova.common.mail;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class LoggingEmailSender implements EmailSenderPort {

    @Override
    public void send(String to, String subject, String textBody) {
        log.info("[EMAIL SIMULÉ] → {} | {} | {}", to, subject, textBody);
    }
}
