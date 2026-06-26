package com.mednova.notification.infrastructure.notification;

import com.mednova.common.mail.EmailSenderPort;
import com.mednova.common.mail.MailProperties;
import com.mednova.notification.domain.model.Notification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class EmailNotificationSender {

    private final EmailSenderPort emailSender;
    private final MailProperties mailProperties;

    public void sendHealthAlertEmail(Notification notification) {
        String recipient = mailProperties.getStaffAlertTo();
        if (recipient == null || recipient.isBlank()) {
            log.warn("MAIL_STAFF_ALERT_TO non configuré — alerte email ignorée : {}", notification.getTitle());
            return;
        }
        emailSender.send(recipient, notification.getTitle(), notification.getMessage());
    }
}
