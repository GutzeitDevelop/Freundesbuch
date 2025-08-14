// Conversation Model for Hive Storage
// 
// Data layer model for conversation persistence
// Version 0.5.0

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

/// Chat participant model
@HiveType(typeId: 11)
@JsonSerializable()
class ChatParticipantModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? photoPath;
  
  @HiveField(3)
  final bool isOnline;
  
  @HiveField(4)
  final DateTime? lastSeen;
  
  @HiveField(5)
  final bool isTyping;
  
  @HiveField(6)
  final String? typingMessage;
  
  ChatParticipantModel({
    required this.id,
    required this.name,
    this.photoPath,
    required this.isOnline,
    this.lastSeen,
    required this.isTyping,
    this.typingMessage,
  });
  
  factory ChatParticipantModel.fromEntity(ChatParticipant participant) {
    return ChatParticipantModel(
      id: participant.id,
      name: participant.name,
      photoPath: participant.photoPath,
      isOnline: participant.isOnline,
      lastSeen: participant.lastSeen,
      isTyping: participant.isTyping,
      typingMessage: participant.typingMessage,
    );
  }
  
  ChatParticipant toEntity() {
    return ChatParticipant(
      id: id,
      name: name,
      photoPath: photoPath,
      isOnline: isOnline,
      lastSeen: lastSeen,
      isTyping: isTyping,
      typingMessage: typingMessage,
    );
  }
  
  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) => 
    _$ChatParticipantModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ChatParticipantModelToJson(this);
}

/// Conversation model for data persistence
@HiveType(typeId: 12)
@JsonSerializable()
class ConversationModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final int type; // ConversationType index
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String? photoPath;
  
  @HiveField(4)
  final List<ChatParticipantModel> participants;
  
  @HiveField(5)
  final MessageModel? lastMessage;
  
  @HiveField(6)
  final int unreadCount;
  
  @HiveField(7)
  final bool isMuted;
  
  @HiveField(8)
  final bool isArchived;
  
  @HiveField(9)
  final bool isPinned;
  
  @HiveField(10)
  final String? themeColor;
  
  @HiveField(11)
  final String? emoji;
  
  @HiveField(12)
  final DateTime createdAt;
  
  @HiveField(13)
  final DateTime updatedAt;
  
  @HiveField(14)
  final String? friendId;
  
  @HiveField(15)
  final String? friendBookId;
  
  @HiveField(16)
  final bool showTypingIndicator;
  
  @HiveField(17)
  final bool showReadReceipts;
  
  @HiveField(18)
  final String? backgroundImagePath;
  
  ConversationModel({
    required this.id,
    required this.type,
    required this.name,
    this.photoPath,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.isMuted,
    required this.isArchived,
    required this.isPinned,
    this.themeColor,
    this.emoji,
    required this.createdAt,
    required this.updatedAt,
    this.friendId,
    this.friendBookId,
    required this.showTypingIndicator,
    required this.showReadReceipts,
    this.backgroundImagePath,
  });
  
  /// Create from entity
  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      type: conversation.type.index,
      name: conversation.name,
      photoPath: conversation.photoPath,
      participants: conversation.participants
          .map((p) => ChatParticipantModel.fromEntity(p))
          .toList(),
      lastMessage: conversation.lastMessage != null
          ? MessageModel.fromEntity(conversation.lastMessage!)
          : null,
      unreadCount: conversation.unreadCount,
      isMuted: conversation.isMuted,
      isArchived: conversation.isArchived,
      isPinned: conversation.isPinned,
      themeColor: conversation.themeColor,
      emoji: conversation.emoji,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      friendId: conversation.friendId,
      friendBookId: conversation.friendBookId,
      showTypingIndicator: conversation.showTypingIndicator,
      showReadReceipts: conversation.showReadReceipts,
      backgroundImagePath: conversation.backgroundImagePath,
    );
  }
  
  /// Convert to entity
  Conversation toEntity() {
    return Conversation(
      id: id,
      type: ConversationType.values[type],
      name: name,
      photoPath: photoPath,
      participants: participants.map((p) => p.toEntity()).toList(),
      lastMessage: lastMessage?.toEntity(),
      unreadCount: unreadCount,
      isMuted: isMuted,
      isArchived: isArchived,
      isPinned: isPinned,
      themeColor: themeColor,
      emoji: emoji,
      createdAt: createdAt,
      updatedAt: updatedAt,
      friendId: friendId,
      friendBookId: friendBookId,
      showTypingIndicator: showTypingIndicator,
      showReadReceipts: showReadReceipts,
      backgroundImagePath: backgroundImagePath,
    );
  }
  
  /// Create from JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) => 
    _$ConversationModelFromJson(json);
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);
}