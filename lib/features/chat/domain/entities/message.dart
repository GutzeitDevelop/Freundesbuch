// Message Entity
// 
// Core message model for chat functionality
// Version 0.5.0

import 'package:equatable/equatable.dart';

/// Types of messages supported in chat
enum MessageType {
  text,
  voice,
  image,
  video,
  location,
  contact,
  system,
}

/// Status of a message
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Message entity representing a single chat message
class Message extends Equatable {
  /// Unique identifier for the message
  final String id;
  
  /// ID of the conversation this message belongs to
  final String conversationId;
  
  /// ID of the sender (user ID or friend ID)
  final String senderId;
  
  /// Name of the sender for display
  final String senderName;
  
  /// Type of message
  final MessageType type;
  
  /// Text content (for text messages)
  final String? content;
  
  /// File path (for voice, image, video)
  final String? filePath;
  
  /// Thumbnail path (for video messages)
  final String? thumbnailPath;
  
  /// Duration in seconds (for voice/video)
  final int? duration;
  
  /// Location data (latitude, longitude)
  final (double lat, double lon)? location;
  
  /// Location address (for location messages)
  final String? locationAddress;
  
  /// Contact ID (for contact sharing)
  final String? sharedContactId;
  
  /// Contact name (for contact sharing)
  final String? contactName;
  
  /// Contact phone (for contact sharing)
  final String? contactPhone;
  
  /// Reply to message ID
  final String? replyToMessageId;
  
  /// Message reactions (emoji -> list of user IDs)
  final Map<String, List<String>>? reactions;
  
  /// Message status
  final MessageStatus status;
  
  /// Timestamp when message was sent
  final DateTime timestamp;
  
  /// Timestamp when message was read
  final DateTime? readAt;
  
  /// Whether message is edited
  final bool isEdited;
  
  /// Timestamp when message was edited
  final DateTime? editedAt;
  
  /// Whether message is deleted
  final bool isDeleted;
  
  /// Link preview data
  final LinkPreview? linkPreview;
  
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.type,
    this.content,
    this.filePath,
    this.thumbnailPath,
    this.duration,
    this.location,
    this.locationAddress,
    this.sharedContactId,
    this.contactName,
    this.contactPhone,
    this.replyToMessageId,
    this.reactions,
    required this.status,
    required this.timestamp,
    this.readAt,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.linkPreview,
  });
  
  /// Check if message is from current user
  bool isFromCurrentUser(String currentUserId) {
    return senderId == currentUserId;
  }
  
  /// Get display time
  String getDisplayTime() {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    MessageType? type,
    String? content,
    String? filePath,
    String? thumbnailPath,
    int? duration,
    (double, double)? location,
    String? locationAddress,
    String? sharedContactId,
    String? contactName,
    String? contactPhone,
    String? replyToMessageId,
    Map<String, List<String>>? reactions,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? readAt,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    LinkPreview? linkPreview,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      type: type ?? this.type,
      content: content ?? this.content,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      locationAddress: locationAddress ?? this.locationAddress,
      sharedContactId: sharedContactId ?? this.sharedContactId,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      reactions: reactions ?? this.reactions,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      readAt: readAt ?? this.readAt,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      linkPreview: linkPreview ?? this.linkPreview,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    senderName,
    type,
    content,
    filePath,
    thumbnailPath,
    duration,
    location,
    locationAddress,
    sharedContactId,
    contactName,
    contactPhone,
    replyToMessageId,
    reactions,
    status,
    timestamp,
    readAt,
    isEdited,
    editedAt,
    isDeleted,
    linkPreview,
  ];
}

/// Link preview data for messages containing URLs
class LinkPreview extends Equatable {
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;
  
  const LinkPreview({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    this.siteName,
  });
  
  @override
  List<Object?> get props => [url, title, description, imageUrl, siteName];
}