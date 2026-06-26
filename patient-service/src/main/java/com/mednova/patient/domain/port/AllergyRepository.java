package com.mednova.patient.domain.port;

import com.mednova.patient.domain.model.Allergy;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AllergyRepository {

    Allergy save(Allergy allergy);

    List<Allergy> findByPatientId(UUID patientId);

    Optional<Allergy> findByIdAndPatientId(UUID id, UUID patientId);

    void deleteById(UUID id);
}
