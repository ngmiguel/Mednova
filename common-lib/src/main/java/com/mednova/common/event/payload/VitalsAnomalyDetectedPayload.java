package com.mednova.common.event.payload;

import java.util.UUID;

public record VitalsAnomalyDetectedPayload(
        UUID readingId,
        UUID patientId,
        String anomalyDetails
) {
}
