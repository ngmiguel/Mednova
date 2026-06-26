package com.mednova.auth.infrastructure.persistence.adapter;

import com.mednova.auth.domain.model.RefreshToken;
import com.mednova.auth.domain.port.RefreshTokenRepository;
import com.mednova.auth.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.auth.infrastructure.persistence.repository.RefreshTokenJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class RefreshTokenRepositoryAdapter implements RefreshTokenRepository {

    private final RefreshTokenJpaRepository refreshTokenJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public RefreshToken save(RefreshToken refreshToken) {
        return persistenceMapper.toDomain(
                refreshTokenJpaRepository.save(persistenceMapper.toEntity(refreshToken))
        );
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<RefreshToken> findByTokenHash(String tokenHash) {
        return refreshTokenJpaRepository.findByTokenHash(tokenHash).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional
    public void revokeAllByUserId(UUID userId) {
        refreshTokenJpaRepository.revokeAllByUserId(userId);
    }
}
