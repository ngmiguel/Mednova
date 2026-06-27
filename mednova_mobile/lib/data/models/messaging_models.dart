class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.patientUserId,
    required this.doctorUserId,
    this.patientId,
    this.doctorId,
    this.subject,
    this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
        id: json['id'] as String,
        patientUserId: json['patientUserId'] as String,
        doctorUserId: json['doctorUserId'] as String,
        patientId: json['patientId'] as String?,
        doctorId: json['doctorId'] as String?,
        subject: json['subject'] as String?,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String? ?? '',
      );

  final String id;
  final String patientUserId;
  final String doctorUserId;
  final String? patientId;
  final String? doctorId;
  final String? subject;
  final String? createdAt;
  final String updatedAt;
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.content,
    required this.sentAt,
    this.readAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderUserId: json['senderUserId'] as String,
        content: json['content'] as String,
        sentAt: json['sentAt'] as String,
        readAt: json['readAt'] as String?,
      );

  final String id;
  final String conversationId;
  final String senderUserId;
  final String content;
  final String sentAt;
  final String? readAt;
}

class ChatContactModel {
  const ChatContactModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.specialty,
    this.preview,
    this.conversationId,
    this.lastActivity,
  });

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? specialty;
  final String? preview;
  final String? conversationId;
  final String? lastActivity;

  String get fullName => '$firstName $lastName';

  ChatContactModel copyWith({
    String? conversationId,
    String? preview,
    String? lastActivity,
  }) {
    return ChatContactModel(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      specialty: specialty,
      preview: preview ?? this.preview,
      conversationId: conversationId ?? this.conversationId,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}
