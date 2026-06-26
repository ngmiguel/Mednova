package com.mednova.common.event.payload;

import java.util.UUID;

public record NotificationSentPayload(
        UUID notificationId,
        UUID patientId,
        String type,
        String channel,
        String title
) {
}
