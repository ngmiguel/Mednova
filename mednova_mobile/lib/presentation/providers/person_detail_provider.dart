import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/specialty_labels.dart';
import '../../data/models/patient_model.dart';
import '../../data/models/user_admin_model.dart';
import 'app_providers.dart';
import 'auth_notifier.dart';

enum PersonDetailKind { patient, doctor, staff }

class PersonDetailField {
  const PersonDetailField({required this.label, required this.value});
  final String label;
  final String value;
}

class PersonDetailViewModel {
  const PersonDetailViewModel({
    required this.kind,
    required this.id,
    this.userId,
    required this.title,
    this.subtitle,
    required this.initials,
    required this.avatarColor,
    required this.fields,
    this.account,
  });

  final PersonDetailKind kind;
  final String id;
  final String? userId;
  final String title;
  final String? subtitle;
  final String initials;
  final Color avatarColor;
  final List<PersonDetailField> fields;
  final UserAccountModel? account;

  PersonDetailViewModel copyWith({UserAccountModel? account}) {
    return PersonDetailViewModel(
      kind: kind,
      id: id,
      userId: userId,
      title: title,
      subtitle: subtitle,
      initials: initials,
      avatarColor: avatarColor,
      fields: fields,
      account: account ?? this.account,
    );
  }
}

class PersonDetailState {
  const PersonDetailState({
    this.view,
    this.loading = false,
    this.saving = false,
    this.error,
  });

  final PersonDetailViewModel? view;
  final bool loading;
  final bool saving;
  final String? error;
}

class PersonDetailNotifier extends Notifier<PersonDetailState> {
  @override
  PersonDetailState build() => const PersonDetailState();

  bool get canBlockAccess {
    final auth = ref.read(authProvider).valueOrNull;
    return auth?.roles.contains(UserRole.admin) ?? false;
  }

  Future<void> openPatient(String id) => _loadPatient(id);

  Future<void> openDoctor(String id) => _loadDoctor(id);

  Future<void> openStaff(String userId) async {
    if (!canBlockAccess) return;
    state = const PersonDetailState(loading: true);
    try {
      final account = await ref.read(userAdminRepositoryProvider).getById(userId);
      state = PersonDetailState(view: _mapStaff(account));
    } catch (_) {
      state = const PersonDetailState(error: 'Impossible de charger la fiche');
    }
  }

  void clear() => state = const PersonDetailState();

  Future<void> _loadPatient(String id) async {
    state = const PersonDetailState(loading: true);
    try {
      final patient = await ref.read(patientRepositoryProvider).getById(id);
      UserAccountModel? account;
      if (canBlockAccess && patient.userId != null) {
        try {
          account = await ref.read(userAdminRepositoryProvider).getById(patient.userId!);
        } catch (_) {}
      }
      state = PersonDetailState(view: _mapPatient(patient, account));
    } catch (_) {
      state = const PersonDetailState(error: 'Impossible de charger la fiche');
    }
  }

  Future<void> _loadDoctor(String id) async {
    state = const PersonDetailState(loading: true);
    try {
      final doctor = await ref.read(doctorRepositoryProvider).getById(id);
      UserAccountModel? account;
      if (canBlockAccess && doctor.userId != null) {
        try {
          account = await ref.read(userAdminRepositoryProvider).getById(doctor.userId!);
        } catch (_) {}
      }
      state = PersonDetailState(view: _mapDoctor(doctor, account));
    } catch (_) {
      state = const PersonDetailState(error: 'Impossible de charger la fiche');
    }
  }

  Future<void> toggleAccess() async {
    final view = state.view;
    if (view?.account == null || !canBlockAccess) return;

    state = PersonDetailState(view: view, saving: true);
    try {
      final next = !view!.account!.enabled;
      final updated = await ref.read(userAdminRepositoryProvider).setAccess(view.account!.id, next);
      state = PersonDetailState(view: view.copyWith(account: updated));
    } catch (_) {
      state = PersonDetailState(view: view, error: 'Échec de la mise à jour des accès');
    }
  }

  bool isSelfAccount() {
    final view = state.view;
    final me = ref.read(authProvider).valueOrNull?.user?.id;
    return view?.userId != null && me != null && view!.userId == me;
  }

  PersonDetailViewModel _mapPatient(PatientModel p, UserAccountModel? account) {
    final fields = <PersonDetailField>[
      PersonDetailField(label: 'Email', value: p.email),
      if (p.phone != null) PersonDetailField(label: 'Téléphone', value: p.phone!),
      if (p.dateOfBirth != null) PersonDetailField(label: 'Date de naissance', value: p.dateOfBirth!),
      if (p.gender != null)
        PersonDetailField(label: 'Genre', value: p.gender == 'M' ? 'Homme' : 'Femme'),
      if (p.bloodType != null)
        PersonDetailField(label: 'Groupe sanguin', value: p.bloodType!.replaceAll('_', ' ')),
      if (p.address != null) PersonDetailField(label: 'Adresse', value: p.address!),
      if (p.emergencyContact != null)
        PersonDetailField(label: 'Contact urgence', value: p.emergencyContact!),
      if (p.createdAt != null) PersonDetailField(label: 'Créé le', value: p.createdAt!),
    ];
    return PersonDetailViewModel(
      kind: PersonDetailKind.patient,
      id: p.id,
      userId: p.userId,
      title: p.fullName,
      subtitle: 'Dossier patient',
      initials: '${p.firstName[0]}${p.lastName[0]}'.toUpperCase(),
      avatarColor: _avatarColor(p.firstName),
      fields: fields,
      account: account,
    );
  }

  PersonDetailViewModel _mapDoctor(DoctorModel d, UserAccountModel? account) {
    final fields = <PersonDetailField>[
      PersonDetailField(label: 'Email', value: d.email),
      if (d.phone != null) PersonDetailField(label: 'Téléphone', value: d.phone!),
      if (d.specialty != null)
        PersonDetailField(label: 'Spécialité', value: SpecialtyLabels.label(d.specialty)),
      if (d.licenseNumber != null) PersonDetailField(label: 'N° licence', value: d.licenseNumber!),
      if (d.bio != null) PersonDetailField(label: 'Bio', value: d.bio!),
      PersonDetailField(label: 'Statut', value: d.active ? 'Disponible' : 'Inactif'),
      if (d.createdAt != null) PersonDetailField(label: 'Créé le', value: d.createdAt!),
    ];
    return PersonDetailViewModel(
      kind: PersonDetailKind.doctor,
      id: d.id,
      userId: d.userId,
      title: d.fullName,
      subtitle: 'Profil médecin',
      initials: '${d.firstName[0]}${d.lastName[0]}'.toUpperCase(),
      avatarColor: _avatarColor(d.firstName),
      fields: fields,
      account: account,
    );
  }

  PersonDetailViewModel _mapStaff(UserAccountModel account) {
    final role = account.roles.isNotEmpty ? account.roles.first.replaceAll('ROLE_', '') : 'USER';
    return PersonDetailViewModel(
      kind: PersonDetailKind.staff,
      id: account.id,
      userId: account.id,
      title: account.fullName,
      subtitle: 'Personnel',
      initials: '${account.firstName[0]}${account.lastName[0]}'.toUpperCase(),
      avatarColor: _avatarColor(account.firstName),
      fields: [
        PersonDetailField(label: 'Email', value: account.email),
        PersonDetailField(label: 'Rôle', value: role),
        PersonDetailField(
          label: '2FA',
          value: account.twoFactorEnabled ? 'Activée' : 'Désactivée',
        ),
        if (account.createdAt != null)
          PersonDetailField(label: 'Créé le', value: account.createdAt!),
      ],
      account: account,
    );
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF0d9488),
      Color(0xFF6366f1),
      Color(0xFF8b5cf6),
      Color(0xFFec4899),
      Color(0xFFf59e0b),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

final personDetailProvider = NotifierProvider<PersonDetailNotifier, PersonDetailState>(
  PersonDetailNotifier.new,
);
