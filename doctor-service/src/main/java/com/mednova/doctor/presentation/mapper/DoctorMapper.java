package com.mednova.doctor.presentation.mapper;

import com.mednova.doctor.domain.model.Availability;
import com.mednova.doctor.domain.model.Doctor;
import com.mednova.doctor.presentation.dto.*;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface DoctorMapper {

    Doctor toDomain(CreateDoctorRequest request);

    Doctor toDomain(UpdateDoctorRequest request);

    DoctorResponse toResponse(Doctor doctor);

    Availability toDomain(CreateAvailabilityRequest request);

    AvailabilityResponse toResponse(Availability availability);
}
