package com.mednova.auth.infrastructure.persistence.mapper;

import com.mednova.auth.domain.model.RefreshToken;
import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.infrastructure.persistence.entity.RefreshTokenEntity;
import com.mednova.auth.infrastructure.persistence.entity.RoleEntity;
import com.mednova.auth.infrastructure.persistence.entity.UserEntity;
import org.springframework.stereotype.Component;

import java.util.Set;
import java.util.stream.Collectors;

@Component
public class PersistenceMapper {

    public User toDomain(UserEntity entity) {
        return User.builder()
                .id(entity.getId())
                .email(entity.getEmail())
                .passwordHash(entity.getPasswordHash())
                .firstName(entity.getFirstName())
                .lastName(entity.getLastName())
                .enabled(entity.isEnabled())
                .twoFactorEnabled(entity.isTwoFactorEnabled())
                .totpSecret(entity.getTotpSecret())
                .roles(entity.getRoles().stream()
                        .map(RoleEntity::getName)
                        .collect(Collectors.toSet()))
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    public UserEntity toEntity(User user, Set<RoleEntity> roleEntities) {
        return UserEntity.builder()
                .id(user.getId())
                .email(user.getEmail())
                .passwordHash(user.getPasswordHash())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .enabled(user.isEnabled())
                .twoFactorEnabled(user.isTwoFactorEnabled())
                .totpSecret(user.getTotpSecret())
                .roles(roleEntities)
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }

    public RefreshToken toDomain(RefreshTokenEntity entity) {
        return RefreshToken.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .tokenHash(entity.getTokenHash())
                .expiresAt(entity.getExpiresAt())
                .revoked(entity.isRevoked())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public RefreshTokenEntity toEntity(RefreshToken token) {
        return RefreshTokenEntity.builder()
                .id(token.getId())
                .userId(token.getUserId())
                .tokenHash(token.getTokenHash())
                .expiresAt(token.getExpiresAt())
                .revoked(token.isRevoked())
                .createdAt(token.getCreatedAt())
                .build();
    }

    public RoleType toRoleType(RoleEntity entity) {
        return entity.getName();
    }
}
