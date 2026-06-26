package com.mednova.common.mail;

public interface EmailSenderPort {

    void send(String to, String subject, String textBody);
}
