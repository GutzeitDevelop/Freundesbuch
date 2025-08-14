// Conversation Entity
// 
// Represents a chat conversation (direct or group)
// Version 0.5.0

import 'package:equatable/equatable.dart';
import 'message.dart';

/// Type of conversation
enum ConversationType {
  direct,  // 1-to-1 chat
  group,   // Group chat (friendbook)
}

/// Participant in a conversation
class ChatParticipant extends Equatable {
  final String id;
  final String name;
  final String? photoPath;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isTyping;
  final String? typingMessage;
  
  const ChatParticipant({
    required this.id,
    required this.name,
    this.photoPath,
    this.isOnline = false,
    this.lastSeen,
    this.isTyping = false,
    this.typingMessage,
  });
  
  ChatParticipant copyWith({
    String? id,
    String? name,
    String? photoPath,
    bool? isOnline,
    DateTime? lastSeen,
    bool? isTyping,
    String? typingMessage,
  }) {
    return ChatParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isTyping: isTyping ?? this.isTyping,
      typingMessage: typingMessage ?? this.typingMessage,
    );
  }
  
  @override
  List<Object?> get props => [id, name, photoPath, isOnline, lastSeen, isTyping, typingMessage];
}

/// Conversation entity representing a chat
class Conversation extends Equatable {
  /// Unique identifier for the conversation
  final String id;
  
  /// Type of conversation
  final ConversationType type;
  
  /// Name of the conversation (friend name or group name)
  final String name;
  
  /// Photo path for the conversation
  final String? photoPath;
  
  /// Participants in the conversation
  final List<ChatParticipant> participants;
  
  /// Last message in the conversation
  final Message? lastMessage;
  
  /// Number of unread messages
  final int unreadCount;
  
  /// Whether conversation is muted
  final bool isMuted;
  
  /// Whether conversation is archived
  final bool isArchived;
  
  /// Whether conversation is pinned
  final bool isPinned;
  
  /// Custom theme color
  final String? themeColor;
  
  /// Custom emoji for the conversation
  final String? emoji;
  
  /// Timestamp when conversation was created
  final DateTime createdAt;
  
  /// Timestamp when conversation was last updated
  final DateTime updatedAt;
  
  /// Friend ID (for direct chats)
  final String? friendId;
  
  /// FriendBook ID (for group chats)
  final String? friendBookId;
  
  /// Whether typing indicators are enabled
  final bool showTypingIndicator;
  
  /// Whether read receipts are enabled
  final bool showReadReceipts;
  
  /// Background image path
  final String? backgroundImagePath;
  
  const Conversation({
    required this.id,
    required this.type,
    required this.name,
    this.photoPath,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isArchived = false,
    this.isPinned = false,
    this.themeColor,
    this.emoji,
    required this.createdAt,
    required this.updatedAt,
    this.friendId,
    this.friendBookId,
    this.showTypingIndicator = true,
    this.showReadReceipts = true,
    this.backgroundImagePath,
  });
  
  /// Get display name for the conversation
  String getDisplayName() {
    if (type == ConversationType.group && friendBookId != null) {
      return '📚 $name';
    }
    return name;
  }
  
  /// Get initials for avatar
  String getInitials() {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
  
  /// Check if any participant is typing
  bool get hasTypingParticipant {
    return participants.any((p) => p.isTyping);
  }
  
  /// Get typing participants
  List<ChatParticipant> get typingParticipants {
    return participants.where((p) => p.isTyping).toList();
  }
  
  /// Get online participants count
  int get onlineParticipantsCount {
    return participants.where((p) => p.isOnline).length;
  }
  
  /// Create a copy with updated fields
  Conversation copyWith({
    String? id,
    ConversationType? type,
    String? name,
    String? photoPath,
    List<ChatParticipant>? participants,
    Message? lastMessage,
    int? unreadCount,
    bool? isMuted,
    bool? isArchived,
    bool? isPinned,
    String? themeColor,
    String? emoji,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? friendId,
    String? friendBookId,
    bool? showTypingIndicator,
    bool? showReadReceipts,
    String? backgroundImagePath,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      themeColor: themeColor ?? this.themeColor,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      friendId: friendId ?? this.friendId,
      friendBookId: friendBookId ?? this.friendBookId,
      showTypingIndicator: showTypingIndicator ?? this.showTypingIndicator,
      showReadReceipts: showReadReceipts ?? this.showReadReceipts,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    type,
    name,
    photoPath,
    participants,
    lastMessage,
    unreadCount,
    isMuted,
    isArchived,
    isPinned,
    themeColor,
    emoji,
    createdAt,
    updatedAt,
    friendId,
    friendBookId,
    showTypingIndicator,
    showReadReceipts,
    backgroundImagePath,
  ];
}