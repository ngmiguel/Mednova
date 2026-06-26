package com.mednova.common.mail;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "mednova.mail")
public class MailProperties {

    /**
     * Activer l'envoi SMTP réel. Si false, les emails sont loggés (mode dev).
     */
    private boolean enabled = false;

    /**
     * Destinataire des alertes santé (staff). Ex. dr.smith@mednova.ai
     */
    private String staffAlertTo = "";

    /**
     * Adresse expéditeur, ex. MedNova AI &lt;noreply@mednova.ai&gt;
     */
    private String from = "MedNova AI <noreply@mednova.ai>";
}
