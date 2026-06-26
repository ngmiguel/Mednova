package com.mednova.patient.domain.port;

import com.mednova.patient.domain.model.Treatment;

import java.util.List;
import java.util.UUID;

public interface TreatmentRepository {

    Treatment save(Treatment treatment);

    List<Treatment> findByPatientId(UUID patientId);
}
