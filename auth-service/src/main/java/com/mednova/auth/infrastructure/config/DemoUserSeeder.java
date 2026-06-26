package com.mednova.auth.infrastructure.config;

import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.domain.port.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Garantit les comptes démo au démarrage (mot de passe synchronisé : password123).
 */
@Component
@Profile("!test")
@RequiredArgsConstructor
@Slf4j
public class DemoUserSeeder implements ApplicationRunner {

    public static final UUID ADMIN_USER_ID = UUID.fromString("a0000001-0000-4000-8000-000000000001");
    public static final UUID DOCTOR_USER_ID = UUID.fromString("a0000002-0000-4000-8000-000000000002");
    public static final UUID NURSE_USER_ID = UUID.fromString("a0000003-0000-4000-8000-000000000003");
    public static final UUID PATIENT_USER_ID = UUID.fromString("70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6");
    public static final UUID AUDITOR_USER_ID = UUID.fromString("a0000004-0000-4000-8000-000000000004");

    private static final String DEMO_PASSWORD = "password123";

    private static final List<DemoUser> DEMO_USERS = List.of(
            new DemoUser(ADMIN_USER_ID, "admin@mednova.ai", "Alice", "Admin", RoleType.ROLE_ADMIN),
            new DemoUser(DOCTOR_USER_ID, "dr.smith@mednova.ai", "John", "Smith", RoleType.ROLE_DOCTOR),
            new DemoUser(UUID.fromString("b2000001-0000-4000-8000-000000000001"), "dr.dubois@mednova.ai", "Claire", "Dubois", RoleType.ROLE_DOCTOR),
            new DemoUser(UUID.fromString("b2000002-0000-4000-8000-000000000002"), "dr.laurent@mednova.ai", "Michel", "Laurent", RoleType.ROLE_DOCTOR),
            new DemoUser(UUID.fromString("b2000003-0000-4000-8000-000000000003"), "dr.alami@mednova.ai", "Fatima", "Alami", RoleType.ROLE_DOCTOR),
            new DemoUser(NURSE_USER_ID, "nurse@mednova.ai", "Emma", "Wilson", RoleType.ROLE_NURSE),
            new DemoUser(UUID.fromString("b3000001-0000-4000-8000-000000000001"), "nurse.martin@mednova.ai", "Julie", "Martin", RoleType.ROLE_NURSE),
            new DemoUser(UUID.fromString("b3000002-0000-4000-8000-000000000002"), "nurse.durand@mednova.ai", "Lucas", "Durand", RoleType.ROLE_NURSE),
            new DemoUser(PATIENT_USER_ID, "patient.test@mednova.ai", "Jean", "Dupont", RoleType.ROLE_PATIENT),
            new DemoUser(UUID.fromString("b1000001-0000-4000-8000-000000000001"), "marie.curie@mednova.ai", "Marie", "Curie", RoleType.ROLE_PATIENT),
            new DemoUser(UUID.fromString("b1000002-0000-4000-8000-000000000002"), "pierre.martin@mednova.ai", "Pierre", "Martin", RoleType.ROLE_PATIENT),
            new DemoUser(UUID.fromString("b1000003-0000-4000-8000-000000000003"), "sophie.bernard@mednova.ai", "Sophie", "Bernard", RoleType.ROLE_PATIENT),
            new DemoUser(UUID.fromString("b1000004-0000-4000-8000-000000000004"), "ahmed.benali@mednova.ai", "Ahmed", "Benali", RoleType.ROLE_PATIENT),
            new DemoUser(AUDITOR_USER_ID, "auditor@mednova.ai", "Marc", "Audit", RoleType.ROLE_AUDITOR)
    );

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        DEMO_USERS.forEach(this::seed);
    }

    private void seed(DemoUser demo) {
        userRepository.findByEmail(demo.email()).ifPresentOrElse(
                existing -> syncDemoAccount(existing, demo),
                () -> createUser(demo)
        );
    }

    private void syncDemoAccount(User user, DemoUser demo) {
        boolean passwordOk = passwordEncoder.matches(DEMO_PASSWORD, user.getPasswordHash());
        boolean needsUpdate = !passwordOk
                || user.isTwoFactorEnabled()
                || user.getRoles() == null
                || user.getRoles().isEmpty()
                || !user.getRoles().contains(demo.role())
                || !user.isEnabled();

        if (!needsUpdate) {
            return;
        }

        userRepository.save(user.toBuilder()
                .passwordHash(passwordEncoder.encode(DEMO_PASSWORD))
                .twoFactorEnabled(false)
                .totpSecret(null)
                .enabled(true)
                .roles(Set.of(demo.role()))
                .updatedAt(Instant.now())
                .build());
        log.info("Compte démo resynchronisé : {} / {}", demo.email(), DEMO_PASSWORD);
    }

    private void createUser(DemoUser demo) {
        Instant now = Instant.now();
        userRepository.save(User.builder()
                .id(demo.id())
                .email(demo.email())
                .passwordHash(passwordEncoder.encode(DEMO_PASSWORD))
                .firstName(demo.firstName())
                .lastName(demo.lastName())
                .enabled(true)
                .twoFactorEnabled(false)
                .roles(Set.of(demo.role()))
                .createdAt(now)
                .updatedAt(now)
                .build());
        log.info("Compte démo créé : {} / {}", demo.email(), DEMO_PASSWORD);
    }

    private record DemoUser(UUID id, String email, String firstName, String lastName, RoleType role) {
    }
}
