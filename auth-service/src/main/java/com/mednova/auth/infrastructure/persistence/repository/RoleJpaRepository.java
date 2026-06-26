package com.mednova.auth.infrastructure.persistence.repository;

import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.infrastructure.persistence.entity.RoleEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleJpaRepository extends JpaRepository<RoleEntity, Long> {

    Optional<RoleEntity> findByName(RoleType name);
}
