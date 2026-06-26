package com.mednova.doctor.infrastructure.persistence.mapper;

import com.mednova.doctor.domain.model.Availability;
import com.mednova.doctor.domain.model.Doctor;
import com.mednova.doctor.infrastructure.persistence.entity.AvailabilityEntity;
import com.mednova.doctor.infrastructure.persistence.entity.DoctorEntity;
import org.springframework.stereotype.Component;

@Component
public class PersistenceMapper {

    public Doctor toDomain(DoctorEntity entity) {
        return Doctor.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .firstName(entity.getFirstName())
                .lastName(entity.getLastName())
                .email(entity.getEmail())
                .phone(entity.getPhone())
                .specialty(entity.getSpecialty())
                .licenseNumber(entity.getLicenseNumber())
                .bio(entity.getBio())
                .active(entity.isActive())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    public DoctorEntity toEntity(Doctor doctor) {
        return DoctorEntity.builder()
                .id(doctor.getId())
                .userId(doctor.getUserId())
                .firstName(doctor.getFirstName())
                .lastName(doctor.getLastName())
                .email(doctor.getEmail())
                .phone(doctor.getPhone())
                .specialty(doctor.getSpecialty())
                .licenseNumber(doctor.getLicenseNumber())
                .bio(doctor.getBio())
                .active(doctor.isActive())
                .createdAt(doctor.getCreatedAt())
                .updatedAt(doctor.getUpdatedAt())
                .build();
    }

    public Availability toDomain(AvailabilityEntity entity) {
        return Availability.builder()
                .id(entity.getId())
                .doctorId(entity.getDoctorId())
                .dayOfWeek(entity.getDayOfWeek())
                .startTime(entity.getStartTime())
                .endTime(entity.getEndTime())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public AvailabilityEntity toEntity(Availability availability) {
        return AvailabilityEntity.builder()
                .id(availability.getId())
                .doctorId(availability.getDoctorId())
                .dayOfWeek(availability.getDayOfWeek())
                .startTime(availability.getStartTime())
                .endTime(availability.getEndTime())
                .createdAt(availability.getCreatedAt())
                .build();
    }
}
