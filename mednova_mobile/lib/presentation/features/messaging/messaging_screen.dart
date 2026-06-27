import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging_models.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/person_detail_provider.dart';
import '../../shared/mednova_page_scaffold.dart';
import '../../shared/person_detail_sheet.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  final _searchCtrl = TextEditingController();
  final _draftCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _draftCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagingNotifierProvider);
    final notifier = ref.read(messagingNotifierProvider.notifier);
    final selected = state.selectedContact;

    if (selected != null) {
      ref.listen<MessagingState>(messagingNotifierProvider, (prev, next) {
        if (next.messages.length > (prev?.messages.length ?? 0)) {
          _scrollToBottom();
        }
      });
      return _ChatThreadView(
        contact: selected,
        messages: state.messages,
        opening: state.opening,
        sending: state.sending,
        draftCtrl: _draftCtrl,
        scrollCtrl: _scrollCtrl,
        isMine: notifier.isMine,
        onBack: notifier.clearSelection,
        onSend: () {
          notifier.sendMessage(_draftCtrl.text);
          _draftCtrl.clear();
        },
        onOpenProfile: () {
          showPersonDetailSheet(
            context,
            ref,
            kind: notifier.isPatient ? PersonDetailKind.doctor : PersonDetailKind.patient,
            id: selected.id,
          );
        },
      );
    }

    final contacts = notifier.filterContacts(_searchCtrl.text);

    return MedNovaPageScaffold(
      title: 'Messagerie',
      subtitle: notifier.isPatient
          ? 'Contactez votre médecin'
          : 'Échanges avec vos patients',
      icon: Icons.chat_bubble_rounded,
      body: state.loading
          ? const MedNovaLoader(message: 'Chargement...')
          : Column(
              children: [
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MedNovaErrorBanner(
                      message: state.error!,
                      onRetry: notifier.loadData,
                    ),
                  ),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un contact...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                if (contacts.isEmpty)
                  const MedNovaEmptyState(
                    icon: Icons.forum_outlined,
                    message: 'Aucun contact disponible',
                  )
                else
                  ...contacts.asMap().entries.map((entry) {
                    final c = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Staggered3DEntrance(
                        index: entry.key,
                        child: Floating3DCard(
                          onTap: () => notifier.selectContact(c),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.auroraViolet.withValues(alpha: 0.2),
                                child: Text('${c.firstName[0]}${c.lastName[0]}'),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    Text(
                                      c.preview ?? c.specialty ?? 'Appuyez pour discuter',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (c.conversationId != null)
                                const Icon(Icons.chat, color: AppColors.auroraTeal, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

class _ChatThreadView extends StatelessWidget {
  const _ChatThreadView({
    required this.contact,
    required this.messages,
    required this.opening,
    required this.sending,
    required this.draftCtrl,
    required this.scrollCtrl,
    required this.isMine,
    required this.onBack,
    required this.onSend,
    required this.onOpenProfile,
  });

  final ChatContactModel contact;
  final List<ChatMessageModel> messages;
  final bool opening;
  final bool sending;
  final TextEditingController draftCtrl;
  final ScrollController scrollCtrl;
  final bool Function(ChatMessageModel) isMine;
  final VoidCallback onBack;
  final VoidCallback onSend;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Parallax3DBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(
                          opening ? 'Ouverture...' : 'Temps réel · actualisation 4s',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: onOpenProfile, icon: const Icon(Icons.person_outline)),
                ],
              ),
            ),
            Expanded(
              child: opening
                  ? const MedNovaLoader(message: 'Ouverture de la conversation...')
                  : messages.isEmpty
                      ? const Center(
                          child: Text('Envoyez votre premier message', style: TextStyle(color: AppColors.textMuted)),
                        )
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, i) {
                            final msg = messages[i];
                            final mine = isMine(msg);
                            return Align(
                              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Staggered3DEntrance(
                                index: i % 6,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                                  decoration: BoxDecoration(
                                    gradient: mine ? AppColors.auroraGradient : AppColors.cardGradient,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: Radius.circular(mine ? 18 : 4),
                                      bottomRight: Radius.circular(mine ? 4 : 18),
                                    ),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: Text(
                                    msg.content,
                                    style: TextStyle(color: mine ? Colors.white : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 250.ms);
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: draftCtrl,
                      decoration: InputDecoration(
                        hintText: 'Votre message...',
                        filled: true,
                        fillColor: AppColors.glassWhite,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: sending ? null : onSend,
                    child: sending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
