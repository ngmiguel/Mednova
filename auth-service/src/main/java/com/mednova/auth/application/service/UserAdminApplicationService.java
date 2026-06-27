package com.mednova.auth.application.service;

import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.domain.port.RefreshTokenRepository;
import com.mednova.auth.domain.port.UserRepository;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.exception.ForbiddenException;
import com.mednova.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserAdminApplicationService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional(readOnly = true)
    public User getById(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Utilisateur", userId));
    }

    @Transactional(readOnly = true)
    public PageResponse<User> list(RoleType role, Pageable pageable) {
        var page = role != null
                ? userRepository.findByRole(role, pageable)
                : userRepository.findAll(pageable);
        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional
    public User updateAccess(UUID userId, boolean enabled, UUID adminId) {
        if (userId.equals(adminId)) {
            throw new ForbiddenException("Vous ne pouvez pas modifier votre propre accès");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Utilisateur", userId));

        if (user.isEnabled() == enabled) {
            return user;
        }

        User updated = user.toBuilder()
                .enabled(enabled)
                .updatedAt(Instant.now())
                .build();
        User saved = userRepository.save(updated);

        if (!enabled) {
            refreshTokenRepository.revokeAllByUserId(userId);
        }

        return saved;
    }

    public void assertAdmin(UUID adminId) {
        User admin = userRepository.findById(adminId)
                .orElseThrow(() -> new ForbiddenException("Accès refusé"));
        if (!admin.getRoles().contains(RoleType.ROLE_ADMIN)) {
            throw new ForbiddenException("Accès réservé à l'administrateur");
        }
    }
}
