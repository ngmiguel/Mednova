package com.mednova.doctor.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Builder
public class Availability {

    private UUID id;
    private UUID doctorId;
    private DayOfWeek dayOfWeek;
    private LocalTime startTime;
    private LocalTime endTime;
    private Instant createdAt;
}
