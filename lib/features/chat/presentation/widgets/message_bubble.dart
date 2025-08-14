// Message Bubble Widget
// 
// Displays individual messages in the chat
// Version 0.5.1

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/message.dart';

/// Message bubble widget for displaying chat messages
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Message? previousMessage;
  final Message? nextMessage;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onReaction;
  
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.previousMessage,
    this.nextMessage,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onReaction,
  });
  
  @override
  Widget build(BuildContext context) {
    final isFirstInGroup = _isFirstInGroup();
    final isLastInGroup = _isLastInGroup();
    
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 8 : 2,
        bottom: isLastInGroup ? 8 : 2,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && isLastInGroup)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                message.senderName[0].toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
            )
          else if (!isMe)
            const SizedBox(width: 32),
          
          if (!isMe) const SizedBox(width: 8),
          
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Container(
                decoration: BoxDecoration(
                  color: isMe 
                      ? AppColors.primary 
                      : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe || !isFirstInGroup ? 16 : 4),
                    topRight: Radius.circular(!isMe || !isFirstInGroup ? 16 : 4),
                    bottomLeft: Radius.circular(isMe || !isLastInGroup ? 16 : 4),
                    bottomRight: Radius.circular(!isMe || !isLastInGroup ? 16 : 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply preview if exists
                    if (message.replyToMessageId != null)
                      _buildReplyPreview(context),
                    
                    // Message content based on type
                    _buildMessageContent(context),
                    
                    // Reactions if any
                    if (message.reactions?.isNotEmpty ?? false)
                      _buildReactions(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(context);
      case MessageType.voice:
        return _buildVoiceMessage(context);
      case MessageType.image:
        return _buildImageMessage(context);
      case MessageType.video:
        return _buildVideoMessage(context);
      case MessageType.location:
        return _buildLocationMessage(context);
      case MessageType.contact:
        return _buildContactMessage(context);
      case MessageType.system:
        return _buildSystemMessage(context);
    }
  }
  
  Widget _buildTextMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content ?? '',
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isEdited)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    'bearbeitet',
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe 
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: isMe 
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.textSecondary,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  _getStatusIcon(),
                  size: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildVoiceMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMe 
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
            ),
            child: IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: isMe ? Colors.white : AppColors.primary,
              ),
              onPressed: () {
                // TODO: Play voice message
              },
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 30,
                decoration: BoxDecoration(
                  color: isMe 
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    '━━━━━━━━━━',
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _formatDuration(message.duration ?? 0),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe 
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe 
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageMessage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Image placeholder
          Container(
            width: 200,
            height: 200,
            color: AppColors.divider,
            child: const Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          ),
          // Time overlay
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _getStatusIcon(),
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVideoMessage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video thumbnail placeholder
          Container(
            width: 200,
            height: 200,
            color: AppColors.divider,
            child: const Center(
              child: Icon(Icons.videocam, size: 48, color: Colors.grey),
            ),
          ),
          // Play button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
            ),
            child: const Icon(
              Icons.play_arrow,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 48, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          if (message.locationAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                message.locationAddress!,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: isMe 
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.contactName ?? 'Kontakt',
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (message.contactPhone != null)
                Text(
                  message.contactPhone!,
                  style: TextStyle(
                    color: isMe 
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: isMe 
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSystemMessage(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content ?? '',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
  
  Widget _buildReplyPreview(BuildContext context) {
    // TODO: Implement reply preview
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe 
            ? Colors.white.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Reply preview'),
    );
  }
  
  Widget _buildReactions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
      child: Wrap(
        spacing: 4,
        children: message.reactions!.entries.map((entry) {
          final emoji = entry.key;
          final users = entry.value;
          final hasReacted = users.contains('current_user');
          
          return GestureDetector(
            onTap: () {
              if (hasReacted) {
                // Remove reaction
                // TODO: Implement remove reaction
              } else {
                onReaction?.call(emoji);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: hasReacted
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasReacted
                      ? AppColors.primary
                      : AppColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  if (users.length > 1) ...[
                    const SizedBox(width: 2),
                    Text(
                      users.length.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: hasReacted
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  IconData _getStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }
  
  bool _isFirstInGroup() {
    if (previousMessage == null) return true;
    if (previousMessage!.senderId != message.senderId) return true;
    
    final timeDiff = message.timestamp.difference(previousMessage!.timestamp);
    return timeDiff.inMinutes > 5;
  }
  
  bool _isLastInGroup() {
    if (nextMessage == null) return true;
    if (nextMessage!.senderId != message.senderId) return true;
    
    final timeDiff = nextMessage!.timestamp.difference(message.timestamp);
    return timeDiff.inMinutes > 5;
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onReply != null)
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Antworten'),
              onTap: () {
                Navigator.pop(context);
                onReply!();
              },
            ),
          if (onEdit != null && message.type == MessageType.text)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Bearbeiten'),
              onTap: () {
                Navigator.pop(context);
                onEdit!();
              },
            ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Kopieren'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Copy message
            },
          ),
          ListTile(
            leading: const Icon(Icons.forward),
            title: const Text('Weiterleiten'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Forward message
            },
          ),
          if (onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                'Löschen',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete!();
              },
            ),
          // Reaction picker
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['👍', '❤️', '😂', '😮', '😢', '🙏']
                  .map((emoji) => GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onReaction?.call(emoji);
                        },
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}