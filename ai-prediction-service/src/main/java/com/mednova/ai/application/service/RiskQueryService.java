package com.mednova.ai.application.service;

import com.mednova.ai.application.security.AiAccessGuard;
import com.mednova.ai.domain.model.RiskAssessment;
import com.mednova.ai.domain.port.RiskAssessmentRepository;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RiskQueryService {

    private final RiskAssessmentRepository riskAssessmentRepository;
    private final AiAccessGuard accessGuard;

    @Transactional(readOnly = true)
    public RiskAssessment getById(UUID id) {
        RiskAssessment assessment = riskAssessmentRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Évaluation de risque", id));
        accessGuard.checkCanRead(assessment);
        return assessment;
    }

    @Transactional(readOnly = true)
    public RiskAssessment getLatestByPatientId(UUID patientId) {
        RiskAssessment assessment = riskAssessmentRepository.findLatestByPatientId(patientId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Évaluation de risque", patientId));
        accessGuard.checkCanRead(assessment);
        return assessment;
    }

    @Transactional(readOnly = true)
    public PageResponse<RiskAssessment> listByPatient(UUID patientId, Pageable pageable) {
        accessGuard.checkCanListPatient(patientId);

        Page<RiskAssessment> page = accessGuard.isPatient()
                ? riskAssessmentRepository.findByPatientUserId(accessGuard.currentUserId(), pageable)
                : riskAssessmentRepository.findByPatientId(patientId, pageable);

        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }
}
