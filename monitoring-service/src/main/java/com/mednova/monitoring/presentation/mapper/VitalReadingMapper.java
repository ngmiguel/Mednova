package com.mednova.monitoring.presentation.mapper;

import com.mednova.monitoring.domain.model.VitalReading;
import com.mednova.monitoring.presentation.dto.CreateVitalReadingRequest;
import com.mednova.monitoring.presentation.dto.VitalReadingResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface VitalReadingMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "anomalyDetected", ignore = true)
    @Mapping(target = "anomalyDetails", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    VitalReading toDomain(CreateVitalReadingRequest request);

    VitalReadingResponse toResponse(VitalReading reading);
}
