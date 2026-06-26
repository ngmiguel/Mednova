package com.mednova.patient.presentation.mapper;

import com.mednova.patient.domain.model.*;
import com.mednova.patient.presentation.dto.*;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface PatientMapper {

    Patient toDomain(CreatePatientRequest request);

    Patient toDomain(UpdatePatientRequest request);

    PatientResponse toResponse(Patient patient);

    MedicalRecord toDomain(CreateMedicalRecordRequest request);

    MedicalRecordResponse toResponse(MedicalRecord record);

    Treatment toDomain(CreateTreatmentRequest request);

    TreatmentResponse toResponse(Treatment treatment);

    Allergy toDomain(CreateAllergyRequest request);

    AllergyResponse toResponse(Allergy allergy);
}
