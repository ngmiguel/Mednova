package com.mednova.common.config;

import com.mednova.common.mail.EmailSenderPort;
import com.mednova.common.mail.LoggingEmailSender;
import com.mednova.common.mail.MailProperties;
import com.mednova.common.mail.SmtpEmailSender;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.mail.javamail.JavaMailSender;

@AutoConfiguration
@ConditionalOnClass(JavaMailSender.class)
@EnableConfigurationProperties(MailProperties.class)
public class MailAutoConfiguration {

    @Bean
    @ConditionalOnProperty(name = "mednova.mail.enabled", havingValue = "true")
    @ConditionalOnMissingBean(EmailSenderPort.class)
    EmailSenderPort smtpEmailSender(JavaMailSender mailSender, MailProperties mailProperties) {
        return new SmtpEmailSender(mailSender, mailProperties);
    }

    @Bean
    @ConditionalOnProperty(name = "mednova.mail.enabled", havingValue = "false", matchIfMissing = true)
    @ConditionalOnMissingBean(EmailSenderPort.class)
    EmailSenderPort loggingEmailSender() {
        return new LoggingEmailSender();
    }
}
