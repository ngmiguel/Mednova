package com.mednova.common.event;

public final class EventTypes {

    private EventTypes() {
    }

    // Patient events
    public static final String PATIENT_CREATED = "PATIENT_CREATED";
    public static final String PATIENT_UPDATED = "PATIENT_UPDATED";
    public static final String MEDICAL_RECORD_UPDATED = "MEDICAL_RECORD_UPDATED";

    // Monitoring events
    public static final String VITALS_RECORDED = "VITALS_RECORDED";
    public static final String VITALS_ANOMALY_DETECTED = "VITALS_ANOMALY_DETECTED";

    // AI events
    public static final String RISK_ASSESSMENT_COMPLETED = "RISK_ASSESSMENT_COMPLETED";
    public static final String HEALTH_ALERT_TRIGGERED = "HEALTH_ALERT_TRIGGERED";

    // Appointment events
    public static final String APPOINTMENT_SCHEDULED = "APPOINTMENT_SCHEDULED";
    public static final String APPOINTMENT_CANCELLED = "APPOINTMENT_CANCELLED";

    // Notification events
    public static final String NOTIFICATION_SENT = "NOTIFICATION_SENT";

    // Audit events
    public static final String AUDIT_LOG_CREATED = "AUDIT_LOG_CREATED";
}
