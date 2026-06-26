package com.mednova.messaging.infrastructure.persistence.repository;

import com.mednova.messaging.infrastructure.persistence.entity.MessageEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface MessageJpaRepository extends JpaRepository<MessageEntity, UUID> {

    List<MessageEntity> findByConversationIdOrderBySentAtAsc(UUID conversationId);

    @Modifying
    @Query("""
            UPDATE MessageEntity m
            SET m.readAt = :readAt
            WHERE m.conversationId = :conversationId
              AND m.senderUserId <> :readerUserId
              AND m.readAt IS NULL
            """)
    int markUnreadAsRead(
            @Param("conversationId") UUID conversationId,
            @Param("readerUserId") UUID readerUserId,
            @Param("readAt") Instant readAt
    );
}
