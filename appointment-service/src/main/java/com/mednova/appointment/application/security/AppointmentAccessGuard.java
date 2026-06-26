package com.mednova.appointment.application.security;

import com.mednova.appointment.domain.model.Appointment;
import com.mednova.common.exception.ForbiddenException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class AppointmentAccessGuard {

    public GatewayUserAuthentication currentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof GatewayUserAuthentication gatewayUser) {
            return gatewayUser;
        }
        throw new ForbiddenException("Utilisateur non authentifié");
    }

    public void checkCanRead(Appointment appointment) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR")) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT")
                && appointment.getPatientUserId() != null
                && appointment.getPatientUserId().equals(user.getUserId())) {
            return;
        }
        if (user.hasRole("ROLE_DOCTOR")
                && appointment.getDoctorUserId() != null
                && appointment.getDoctorUserId().equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Accès refusé à ce rendez-vous");
    }

    public void checkCanList() {
        currentUser();
    }

    public void checkCanCreate() {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_PATIENT")) {
            return;
        }
        throw new ForbiddenException("Vous n'avez pas les droits pour planifier un rendez-vous");
    }

    public void checkCanUpdate(Appointment appointment) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_NURSE")) {
            return;
        }
        if (user.hasRole("ROLE_PATIENT")
                && appointment.getPatientUserId() != null
                && appointment.getPatientUserId().equals(user.getUserId())) {
            return;
        }
        if (user.hasRole("ROLE_DOCTOR")
                && appointment.getDoctorUserId() != null
                && appointment.getDoctorUserId().equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Vous n'avez pas les droits pour modifier ce rendez-vous");
    }

    public void checkCanCancel(Appointment appointment) {
        checkCanUpdate(appointment);
    }

    public void checkCanConfirm(Appointment appointment) {
        var user = currentUser();
        if (user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_NURSE")) {
            return;
        }
        if (user.hasRole("ROLE_DOCTOR")
                && appointment.getDoctorUserId() != null
                && appointment.getDoctorUserId().equals(user.getUserId())) {
            return;
        }
        throw new ForbiddenException("Seul le médecin concerné peut confirmer ce rendez-vous");
    }

    public void checkCanDelete() {
        if (!currentUser().hasRole("ROLE_ADMIN")) {
            throw new ForbiddenException("Seul un administrateur peut supprimer un rendez-vous");
        }
    }

    public UUID currentUserId() {
        return currentUser().getUserId();
    }

    public boolean isStaff() {
        var user = currentUser();
        return user.hasRole("ROLE_ADMIN") || user.hasRole("ROLE_NURSE") || user.hasRole("ROLE_AUDITOR");
    }

    public boolean isPatient() {
        return currentUser().hasRole("ROLE_PATIENT");
    }

    public boolean isDoctor() {
        return currentUser().hasRole("ROLE_DOCTOR");
    }
}
