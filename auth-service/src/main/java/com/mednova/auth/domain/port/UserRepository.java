package com.mednova.auth.domain.port;

import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.domain.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository {

    User save(User user);

    Optional<User> findById(UUID id);

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    Page<User> findAll(Pageable pageable);

    Page<User> findByRole(RoleType role, Pageable pageable);
}
