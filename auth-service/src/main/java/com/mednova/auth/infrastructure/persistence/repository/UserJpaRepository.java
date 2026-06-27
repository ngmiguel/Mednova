package com.mednova.auth.infrastructure.persistence.repository;

import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.infrastructure.persistence.entity.UserEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface UserJpaRepository extends JpaRepository<UserEntity, UUID> {

    Optional<UserEntity> findByEmail(String email);

    boolean existsByEmail(String email);

    @Query("SELECT DISTINCT u FROM UserEntity u JOIN u.roles r WHERE r.name = :role")
    Page<UserEntity> findByRoleName(@Param("role") RoleType role, Pageable pageable);
}
