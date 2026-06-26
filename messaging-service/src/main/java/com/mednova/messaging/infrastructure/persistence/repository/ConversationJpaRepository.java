package com.mednova.messaging.infrastructure.persistence.repository;

import com.mednova.messaging.infrastructure.persistence.entity.ConversationEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConversationJpaRepository extends JpaRepository<ConversationEntity, UUID> {

    Optional<ConversationEntity> findByPatientUserIdAndDoctorUserId(UUID patientUserId, UUID doctorUserId);

    List<ConversationEntity> findByPatientUserIdOrderByUpdatedAtDesc(UUID patientUserId);

    List<ConversationEntity> findByDoctorUserIdOrderByUpdatedAtDesc(UUID doctorUserId);

    List<ConversationEntity> findAllByOrderByUpdatedAtDesc();
}
