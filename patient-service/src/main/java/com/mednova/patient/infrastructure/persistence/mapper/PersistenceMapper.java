package com.mednova.patient.infrastructure.persistence.mapper;

import com.mednova.patient.domain.model.*;
import com.mednova.patient.infrastructure.persistence.entity.*;
import org.springframework.stereotype.Component;

@Component
public class PersistenceMapper {

    public Patient toDomain(PatientEntity entity) {
        return Patient.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .firstName(entity.getFirstName())
                .lastName(entity.getLastName())
                .email(entity.getEmail())
                .phone(entity.getPhone())
                .dateOfBirth(entity.getDateOfBirth())
                .bloodType(entity.getBloodType())
                .gender(entity.getGender())
                .address(entity.getAddress())
                .emergencyContact(entity.getEmergencyContact())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    public PatientEntity toEntity(Patient patient) {
        return PatientEntity.builder()
                .id(patient.getId())
                .userId(patient.getUserId())
                .firstName(patient.getFirstName())
                .lastName(patient.getLastName())
                .email(patient.getEmail())
                .phone(patient.getPhone())
                .dateOfBirth(patient.getDateOfBirth())
                .bloodType(patient.getBloodType())
                .gender(patient.getGender())
                .address(patient.getAddress())
                .emergencyContact(patient.getEmergencyContact())
                .createdAt(patient.getCreatedAt())
                .updatedAt(patient.getUpdatedAt())
                .build();
    }

    public MedicalRecord toDomain(MedicalRecordEntity entity) {
        return MedicalRecord.builder()
                .id(entity.getId())
                .patientId(entity.getPatientId())
                .doctorId(entity.getDoctorId())
                .diagnosis(entity.getDiagnosis())
                .notes(entity.getNotes())
                .visitDate(entity.getVisitDate())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public MedicalRecordEntity toEntity(MedicalRecord record) {
        return MedicalRecordEntity.builder()
                .id(record.getId())
                .patientId(record.getPatientId())
                .doctorId(record.getDoctorId())
                .diagnosis(record.getDiagnosis())
                .notes(record.getNotes())
                .visitDate(record.getVisitDate())
                .createdAt(record.getCreatedAt())
                .build();
    }

    public Treatment toDomain(TreatmentEntity entity) {
        return Treatment.builder()
                .id(entity.getId())
                .patientId(entity.getPatientId())
                .medication(entity.getMedication())
                .dosage(entity.getDosage())
                .frequency(entity.getFrequency())
                .startDate(entity.getStartDate())
                .endDate(entity.getEndDate())
                .prescribedBy(entity.getPrescribedBy())
                .active(entity.isActive())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public TreatmentEntity toEntity(Treatment treatment) {
        return TreatmentEntity.builder()
                .id(treatment.getId())
                .patientId(treatment.getPatientId())
                .medication(treatment.getMedication())
                .dosage(treatment.getDosage())
                .frequency(treatment.getFrequency())
                .startDate(treatment.getStartDate())
                .endDate(treatment.getEndDate())
                .prescribedBy(treatment.getPrescribedBy())
                .active(treatment.isActive())
                .createdAt(treatment.getCreatedAt())
                .build();
    }

    public Allergy toDomain(AllergyEntity entity) {
        return Allergy.builder()
                .id(entity.getId())
                .patientId(entity.getPatientId())
                .allergen(entity.getAllergen())
                .severity(entity.getSeverity())
                .reaction(entity.getReaction())
                .diagnosedAt(entity.getDiagnosedAt())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public AllergyEntity toEntity(Allergy allergy) {
        return AllergyEntity.builder()
                .id(allergy.getId())
                .patientId(allergy.getPatientId())
                .allergen(allergy.getAllergen())
                .severity(allergy.getSeverity())
                .reaction(allergy.getReaction())
                .diagnosedAt(allergy.getDiagnosedAt())
                .createdAt(allergy.getCreatedAt())
                .build();
    }
}
