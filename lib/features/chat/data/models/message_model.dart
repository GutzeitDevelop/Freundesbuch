// Message Model for Hive Storage
// 
// Data layer model for message persistence
// Version 0.5.0

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/message.dart';

part 'message_model.g.dart';

/// Message model for data persistence
@HiveType(typeId: 10)
@JsonSerializable()
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String conversationId;
  
  @HiveField(2)
  final String senderId;
  
  @HiveField(3)
  final String senderName;
  
  @HiveField(4)
  final int type; // MessageType index
  
  @HiveField(5)
  String? content;
  
  @HiveField(6)
  final String? filePath;
  
  @HiveField(7)
  final String? thumbnailPath;
  
  @HiveField(8)
  final int? duration;
  
  @HiveField(9)
  final double? locationLat;
  
  @HiveField(10)
  final double? locationLon;
  
  @HiveField(11)
  final String? locationAddress;
  
  @HiveField(12)
  final String? sharedContactId;
  
  @HiveField(13)
  final String? replyToMessageId;
  
  @HiveField(14)
  Map<String, List<String>>? reactions;
  
  @HiveField(15)
  int status; // MessageStatus index
  
  @HiveField(16)
  final DateTime timestamp;
  
  @HiveField(17)
  DateTime? readAt;
  
  @HiveField(18)
  bool isEdited;
  
  @HiveField(19)
  DateTime? editedAt;
  
  @HiveField(20)
  bool isDeleted;
  
  @HiveField(21)
  final String? linkPreviewUrl;
  
  @HiveField(22)
  final String? linkPreviewTitle;
  
  @HiveField(23)
  final String? linkPreviewDescription;
  
  @HiveField(24)
  final String? linkPreviewImageUrl;
  
  @HiveField(25)
  final String? linkPreviewSiteName;
  
  @HiveField(26)
  final String? contactName;
  
  @HiveField(27)
  final String? contactPhone;
  
  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.type,
    this.content,
    this.filePath,
    this.thumbnailPath,
    this.duration,
    this.locationLat,
    this.locationLon,
    this.locationAddress,
    this.sharedContactId,
    this.replyToMessageId,
    this.reactions,
    required this.status,
    required this.timestamp,
    this.readAt,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    this.linkPreviewUrl,
    this.linkPreviewTitle,
    this.linkPreviewDescription,
    this.linkPreviewImageUrl,
    this.linkPreviewSiteName,
    this.contactName,
    this.contactPhone,
  });
  
  /// Create from entity
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      senderName: message.senderName,
      type: message.type.index,
      content: message.content,
      filePath: message.filePath,
      thumbnailPath: message.thumbnailPath,
      duration: message.duration,
      locationLat: message.location?.$1,
      locationLon: message.location?.$2,
      locationAddress: message.locationAddress,
      sharedContactId: message.sharedContactId,
      replyToMessageId: message.replyToMessageId,
      reactions: message.reactions,
      status: message.status.index,
      timestamp: message.timestamp,
      readAt: message.readAt,
      isEdited: message.isEdited,
      editedAt: message.editedAt,
      isDeleted: message.isDeleted,
      linkPreviewUrl: message.linkPreview?.url,
      linkPreviewTitle: message.linkPreview?.title,
      linkPreviewDescription: message.linkPreview?.description,
      linkPreviewImageUrl: message.linkPreview?.imageUrl,
      linkPreviewSiteName: message.linkPreview?.siteName,
      contactName: message.contactName,
      contactPhone: message.contactPhone,
    );
  }
  
  /// Convert to entity
  Message toEntity() {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      type: MessageType.values[type],
      content: content,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      duration: duration,
      location: (locationLat != null && locationLon != null) 
          ? (locationLat!, locationLon!) 
          : null,
      locationAddress: locationAddress,
      sharedContactId: sharedContactId,
      contactName: contactName,
      contactPhone: contactPhone,
      replyToMessageId: replyToMessageId,
      reactions: reactions,
      status: MessageStatus.values[status],
      timestamp: timestamp,
      readAt: readAt,
      isEdited: isEdited,
      editedAt: editedAt,
      isDeleted: isDeleted,
      linkPreview: linkPreviewUrl != null
          ? LinkPreview(
              url: linkPreviewUrl!,
              title: linkPreviewTitle,
              description: linkPreviewDescription,
              imageUrl: linkPreviewImageUrl,
              siteName: linkPreviewSiteName,
            )
          : null,
    );
  }
  
  /// Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) => 
    _$MessageModelFromJson(json);
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}