import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/specialty_labels.dart';
import '../../data/models/messaging_models.dart';
import '../../data/models/patient_model.dart';
import 'app_providers.dart';
import 'auth_notifier.dart';

class MessagingState {
  const MessagingState({
    this.contacts = const [],
    this.messages = const [],
    this.selectedContact,
    this.loading = true,
    this.opening = false,
    this.sending = false,
    this.error,
    this.doctorSelfId,
  });

  final List<ChatContactModel> contacts;
  final List<ChatMessageModel> messages;
  final ChatContactModel? selectedContact;
  final bool loading;
  final bool opening;
  final bool sending;
  final String? error;
  final String? doctorSelfId;

  MessagingState copyWith({
    List<ChatContactModel>? contacts,
    List<ChatMessageModel>? messages,
    ChatContactModel? selectedContact,
    bool clearSelected = false,
    bool? loading,
    bool? opening,
    bool? sending,
    String? error,
    bool clearError = false,
    String? doctorSelfId,
  }) {
    return MessagingState(
      contacts: contacts ?? this.contacts,
      messages: messages ?? this.messages,
      selectedContact: clearSelected ? null : (selectedContact ?? this.selectedContact),
      loading: loading ?? this.loading,
      opening: opening ?? this.opening,
      sending: sending ?? this.sending,
      error: clearError ? null : (error ?? this.error),
      doctorSelfId: doctorSelfId ?? this.doctorSelfId,
    );
  }
}

class MessagingNotifier extends Notifier<MessagingState> {
  Timer? _pollTimer;

  @override
  MessagingState build() {
    ref.onDispose(_stopPolling);
    Future.microtask(loadData);
    return const MessagingState();
  }

  bool get isPatient {
    final roles = ref.read(authProvider).valueOrNull?.roles ?? [];
    return roles.contains(UserRole.patient);
  }

  bool get isDoctor {
    final roles = ref.read(authProvider).valueOrNull?.roles ?? [];
    return roles.contains(UserRole.doctor);
  }

  Future<void> loadData() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(messagingRepositoryProvider);
      final conversations = await repo.listConversations();

      List<PatientModel> patients = [];
      List<DoctorModel> doctors = [];
      String? doctorSelfId;

      if (isPatient) {
        doctors = await ref.read(doctorRepositoryProvider).list(size: 100);
      } else {
        patients = await ref.read(patientRepositoryProvider).list(size: 100);
        if (isDoctor) {
          final allDoctors = await ref.read(doctorRepositoryProvider).list(size: 100);
          final me = ref.read(authProvider).valueOrNull?.user?.id;
          DoctorModel? selfDoctor;
          for (final d in allDoctors) {
            if (d.userId == me) {
              selfDoctor = d;
              break;
            }
          }
          doctorSelfId = selfDoctor?.id ?? me;
        }
      }

      final people = isPatient
          ? doctors
              .map((d) => _PersonRow(id: d.id, userId: d.userId, firstName: d.firstName, lastName: d.lastName, specialty: d.specialty))
              .toList()
          : patients
              .map((p) => _PersonRow(id: p.id, userId: p.userId, firstName: p.firstName, lastName: p.lastName))
              .toList();

      final contacts = _buildContacts(people, conversations);
      state = state.copyWith(
        contacts: contacts,
        loading: false,
        doctorSelfId: doctorSelfId,
      );
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Impossible de charger la messagerie');
    }
  }

  Future<void> selectContact(ChatContactModel contact) async {
    state = state.copyWith(selectedContact: contact, messages: []);
    if (contact.conversationId != null) {
      await loadMessages(contact.conversationId!);
      _startPolling(contact.conversationId!);
      return;
    }
    await _openConversation(contact);
  }

  void clearSelection() {
    _stopPolling();
    state = state.copyWith(clearSelected: true, messages: []);
  }

  Future<void> sendMessage(String content) async {
    final contact = state.selectedContact;
    final conversationId = contact?.conversationId;
    if (conversationId == null || content.trim().isEmpty) return;

    state = state.copyWith(sending: true);
    try {
      final msg = await ref.read(messagingRepositoryProvider).sendMessage(conversationId, content.trim());
      state = state.copyWith(
        messages: [...state.messages, msg],
        sending: false,
      );
      _touchContact(contact!.id, msg.content, msg.sentAt);
    } catch (_) {
      state = state.copyWith(sending: false, error: 'Envoi impossible');
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final repo = ref.read(messagingRepositoryProvider);
      final messages = await repo.listMessages(conversationId);
      await repo.markRead(conversationId);
      state = state.copyWith(messages: messages);
      final contact = state.selectedContact;
      final last = messages.isNotEmpty ? messages.last : null;
      if (last != null && contact != null) {
        _touchContact(contact.id, last.content, last.sentAt);
      }
    } catch (_) {}
  }

  List<ChatContactModel> filterContacts(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return state.contacts;
    return state.contacts
        .where((c) => c.fullName.toLowerCase().contains(q))
        .toList();
  }

  bool isMine(ChatMessageModel msg) {
    final me = ref.read(authProvider).valueOrNull?.user?.id;
    return me != null && msg.senderUserId == me;
  }

  void _startPolling(String conversationId) {
    _stopPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      loadMessages(conversationId);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _openConversation(ChatContactModel contact) async {
    final me = ref.read(authProvider).valueOrNull?.user;
    if (me == null) return;

    state = state.copyWith(opening: true);
    try {
      final body = isPatient
          ? {
              'patientUserId': me.id,
              'doctorUserId': contact.userId,
              'patientId': me.id,
              'doctorId': contact.id,
            }
          : {
              'patientUserId': contact.userId,
              'doctorUserId': me.id,
              'patientId': contact.id,
              'doctorId': state.doctorSelfId ?? me.id,
            };

      final conv = await ref.read(messagingRepositoryProvider).createConversation(
            patientUserId: body['patientUserId']!,
            doctorUserId: body['doctorUserId']!,
            patientId: body['patientId'],
            doctorId: body['doctorId'],
          );

      final updated = contact.copyWith(conversationId: conv.id, lastActivity: conv.updatedAt);
      final contacts = state.contacts
          .map((c) => c.id == contact.id ? updated : c)
          .toList();

      state = state.copyWith(
        contacts: contacts,
        selectedContact: updated,
        opening: false,
      );
      await loadMessages(conv.id);
      _startPolling(conv.id);
    } catch (_) {
      state = state.copyWith(opening: false, error: 'Impossible d\'ouvrir la conversation');
    }
  }

  List<ChatContactModel> _buildContacts(List<_PersonRow> people, List<ConversationModel> conversations) {
    final convByPeer = <String, ConversationModel>{};
    for (final c in conversations) {
      final peerUserId = isPatient ? c.doctorUserId : c.patientUserId;
      convByPeer[peerUserId] = c;
    }

    final contacts = people.map((p) {
      final userId = p.userId ?? p.id;
      final conv = convByPeer[userId];
      return ChatContactModel(
        id: p.id,
        userId: userId,
        firstName: p.firstName,
        lastName: p.lastName,
        specialty: isPatient ? SpecialtyLabels.label(p.specialty) : null,
        conversationId: conv?.id,
        lastActivity: conv?.updatedAt,
      );
    }).toList();

    contacts.sort((a, b) {
      if (a.lastActivity != null && b.lastActivity != null) {
        return b.lastActivity!.compareTo(a.lastActivity!);
      }
      if (a.lastActivity != null) return -1;
      if (b.lastActivity != null) return 1;
      return a.lastName.compareTo(b.lastName);
    });
    return contacts;
  }

  void _touchContact(String contactId, String preview, String at) {
    final updated = state.contacts.map((c) {
      return c.id == contactId ? c.copyWith(preview: preview, lastActivity: at) : c;
    }).toList();
    updated.sort((a, b) {
      if (a.lastActivity != null && b.lastActivity != null) {
        return b.lastActivity!.compareTo(a.lastActivity!);
      }
      return 0;
    });
    state = state.copyWith(contacts: updated);
  }
}

class _PersonRow {
  const _PersonRow({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    this.specialty,
  });
  final String id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String? specialty;
}

final messagingNotifierProvider = NotifierProvider<MessagingNotifier, MessagingState>(
  MessagingNotifier.new,
);
