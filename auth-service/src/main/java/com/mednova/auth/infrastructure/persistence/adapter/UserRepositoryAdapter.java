package com.mednova.auth.infrastructure.persistence.adapter;

import com.mednova.auth.domain.model.RefreshToken;
import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.domain.port.RefreshTokenRepository;
import com.mednova.auth.domain.port.UserRepository;
import com.mednova.auth.infrastructure.persistence.entity.RoleEntity;
import com.mednova.auth.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.auth.infrastructure.persistence.repository.RefreshTokenJpaRepository;
import com.mednova.auth.infrastructure.persistence.repository.RoleJpaRepository;
import com.mednova.auth.infrastructure.persistence.repository.UserJpaRepository;
import com.mednova.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class UserRepositoryAdapter implements UserRepository {

    private final UserJpaRepository userJpaRepository;
    private final RoleJpaRepository roleJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public User save(User user) {
        Set<RoleEntity> roleEntities = user.getRoles().stream()
                .map(this::loadRole)
                .collect(Collectors.toSet());

        return persistenceMapper.toDomain(
                userJpaRepository.save(persistenceMapper.toEntity(user, roleEntities))
        );
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findById(UUID id) {
        return userJpaRepository.findById(id).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByEmail(String email) {
        return userJpaRepository.findByEmail(email).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userJpaRepository.existsByEmail(email);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> findAll(Pageable pageable) {
        return userJpaRepository.findAll(pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> findByRole(RoleType role, Pageable pageable) {
        return userJpaRepository.findByRoleName(role, pageable).map(persistenceMapper::toDomain);
    }

    private RoleEntity loadRole(RoleType roleType) {
        return roleJpaRepository.findByName(roleType)
                .orElseThrow(() -> new BusinessException("Rôle introuvable : " + roleType));
    }
}
