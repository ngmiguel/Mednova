package com.mednova.doctor.application.service;

import com.mednova.common.exception.BusinessException;
import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.doctor.application.security.DoctorAccessGuard;
import com.mednova.doctor.domain.model.Availability;
import com.mednova.doctor.domain.port.AvailabilityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AvailabilityApplicationService {

    private final AvailabilityRepository availabilityRepository;
    private final DoctorApplicationService doctorApplicationService;
    private final DoctorAccessGuard accessGuard;

    @Transactional
    public Availability create(UUID doctorId, Availability availability) {
        var doctor = doctorApplicationService.getByIdInternal(doctorId);
        accessGuard.checkCanManageAvailability(doctor);

        if (!availability.getEndTime().isAfter(availability.getStartTime())) {
            throw new BusinessException("L'heure de fin doit être après l'heure de début");
        }

        Availability toSave = Availability.builder()
                .id(UUID.randomUUID())
                .doctorId(doctorId)
                .dayOfWeek(availability.getDayOfWeek())
                .startTime(availability.getStartTime())
                .endTime(availability.getEndTime())
                .createdAt(Instant.now())
                .build();
        return availabilityRepository.save(toSave);
    }

    @Transactional(readOnly = true)
    public List<Availability> listByDoctor(UUID doctorId) {
        accessGuard.checkCanRead();
        doctorApplicationService.getByIdInternal(doctorId);
        return availabilityRepository.findByDoctorId(doctorId);
    }

    @Transactional
    public void delete(UUID doctorId, UUID availabilityId) {
        var doctor = doctorApplicationService.getByIdInternal(doctorId);
        accessGuard.checkCanManageAvailability(doctor);

        availabilityRepository.findByIdAndDoctorId(availabilityId, doctorId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Disponibilité", availabilityId));
        availabilityRepository.deleteById(availabilityId);
    }
}
