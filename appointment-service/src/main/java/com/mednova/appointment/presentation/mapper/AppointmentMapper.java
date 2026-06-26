package com.mednova.appointment.presentation.mapper;

import com.mednova.appointment.domain.model.Appointment;
import com.mednova.appointment.presentation.dto.AppointmentResponse;
import com.mednova.appointment.presentation.dto.CreateAppointmentRequest;
import com.mednova.appointment.presentation.dto.UpdateAppointmentRequest;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AppointmentMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "durationMinutes", expression = "java(request.durationMinutes() != null ? request.durationMinutes() : 30)")
    Appointment toDomain(CreateAppointmentRequest request);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "patientId", ignore = true)
    @Mapping(target = "doctorId", ignore = true)
    @Mapping(target = "patientUserId", ignore = true)
    @Mapping(target = "doctorUserId", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "durationMinutes", expression = "java(request.durationMinutes() != null ? request.durationMinutes() : 0)")
    Appointment toDomain(UpdateAppointmentRequest request);

    AppointmentResponse toResponse(Appointment appointment);
}
