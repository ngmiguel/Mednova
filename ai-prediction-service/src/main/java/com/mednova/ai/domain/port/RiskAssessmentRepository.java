package com.mednova.ai.domain.port;

import com.mednova.ai.domain.model.RiskAssessment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;
import java.util.UUID;

public interface RiskAssessmentRepository {

    RiskAssessment save(RiskAssessment assessment);

    Optional<RiskAssessment> findById(UUID id);

    Optional<RiskAssessment> findLatestByPatientId(UUID patientId);

    Page<RiskAssessment> findByPatientId(UUID patientId, Pageable pageable);

    Page<RiskAssessment> findByPatientUserId(UUID patientUserId, Pageable pageable);
}
