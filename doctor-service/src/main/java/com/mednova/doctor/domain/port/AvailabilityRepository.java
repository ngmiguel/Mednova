package com.mednova.doctor.domain.port;

import com.mednova.doctor.domain.model.Availability;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AvailabilityRepository {

    Availability save(Availability availability);

    List<Availability> findByDoctorId(UUID doctorId);

    Optional<Availability> findByIdAndDoctorId(UUID id, UUID doctorId);

    void deleteById(UUID id);
}
