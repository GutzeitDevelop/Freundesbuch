// Chat Page
// 
// Main chat interface for messaging with friends
// Version 0.5.1

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_widget.dart';

/// Main chat page for a conversation
class ChatPage extends ConsumerStatefulWidget {
  final Conversation conversation;
  
  const ChatPage({
    super.key,
    required this.conversation,
  });
  
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  Message? _replyToMessage;
  
  @override
  void initState() {
    super.initState();
    // Mark conversation as read when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).markAsRead(widget.conversation.id);
    });
    
    // Setup scroll listener for loading more messages
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent && !_isLoading) {
      // Load more messages when reaching the top
      _loadMoreMessages();
    }
  }
  
  Future<void> _loadMoreMessages() async {
    setState(() => _isLoading = true);
    // In a real app, this would load older messages
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversation.id));
    final typingUsersAsync = ref.watch(typingUsersProvider(widget.conversation.id));
    
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () => _showConversationInfo(),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: widget.conversation.photoPath != null
                    ? AssetImage(widget.conversation.photoPath!)
                    : null,
                child: widget.conversation.photoPath == null
                    ? Text(
                        widget.conversation.emoji ?? 
                        widget.conversation.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 16),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conversation.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    // Online status or typing indicator
                    typingUsersAsync.when(
                      data: (typingUsers) {
                        if (typingUsers.isNotEmpty) {
                          return Text(
                            'schreibt...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          );
                        }
                        return _buildStatusText();
                      },
                      loading: () => _buildStatusText(),
                      error: (_, __) => _buildStatusText(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (widget.conversation.type == ConversationType.direct)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => _makeCall(),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final message = messages[index];
                    final previousMessage = index < messages.length - 1 
                        ? messages[index + 1] 
                        : null;
                    final nextMessage = index > 0 
                        ? messages[index - 1] 
                        : null;
                    
                    // Check if we need to show date separator
                    final showDateSeparator = _shouldShowDateSeparator(
                      message,
                      previousMessage,
                    );
                    
                    return Column(
                      children: [
                        if (showDateSeparator)
                          _buildDateSeparator(message.timestamp),
                        MessageBubble(
                          message: message,
                          isMe: message.senderId == 'current_user',
                          previousMessage: previousMessage,
                          nextMessage: nextMessage,
                          onReply: () => _setReplyTo(message),
                          onEdit: message.senderId == 'current_user'
                              ? () => _editMessage(message)
                              : null,
                          onDelete: () => _deleteMessage(message),
                          onReaction: (emoji) => _addReaction(message, emoji),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text('Fehler: $error'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(
                        messagesProvider(widget.conversation.id),
                      ),
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Reply preview
          if (_replyToMessage != null)
            _buildReplyPreview(),
          
          // Input area
          ChatInputWidget(
            controller: _messageController,
            conversationId: widget.conversation.id,
            replyToMessage: _replyToMessage,
            onSend: _sendMessage,
            onTyping: (isTyping) => _setTypingStatus(isTyping),
            onCancelReply: () => setState(() => _replyToMessage = null),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusText() {
    if (widget.conversation.type == ConversationType.group) {
      final participantCount = widget.conversation.participants.length;
      return Text(
        '$participantCount Teilnehmer',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      );
    }
    
    // For direct chats, show online status
    final otherParticipant = widget.conversation.participants
        .firstWhere((p) => p.id != 'current_user');
    
    if (otherParticipant.isOnline) {
      return Text(
        'Online',
        style: TextStyle(
          fontSize: 12,
          color: Colors.green,
        ),
      );
    } else if (otherParticipant.lastSeen != null) {
      final timeAgo = _formatLastSeen(otherParticipant.lastSeen!);
      return Text(
        'Zuletzt online: $timeAgo',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Noch keine Nachrichten',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sende die erste Nachricht!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    String dateText;
    
    if (difference.inDays == 0) {
      dateText = 'Heute';
    } else if (difference.inDays == 1) {
      dateText = 'Gestern';
    } else if (difference.inDays < 7) {
      dateText = DateFormat('EEEE', 'de_DE').format(date);
    } else {
      dateText = DateFormat('d. MMMM yyyy', 'de_DE').format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _replyToMessage!.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _getMessagePreview(_replyToMessage!),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _replyToMessage = null),
          ),
        ],
      ),
    );
  }
  
  bool _shouldShowDateSeparator(Message message, Message? previousMessage) {
    if (previousMessage == null) return true;
    
    final messageDate = DateTime(
      message.timestamp.year,
      message.timestamp.month,
      message.timestamp.day,
    );
    
    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );
    
    return messageDate != previousDate;
  }
  
  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'gerade eben';
    } else if (difference.inMinutes < 60) {
      return 'vor ${difference.inMinutes} Min.';
    } else if (difference.inHours < 24) {
      return 'vor ${difference.inHours} Std.';
    } else if (difference.inDays < 7) {
      return 'vor ${difference.inDays} Tagen';
    } else {
      return DateFormat('dd.MM.yyyy').format(lastSeen);
    }
  }
  
  String _getMessagePreview(Message message) {
    switch (message.type) {
      case MessageType.text:
        return message.content ?? '';
      case MessageType.voice:
        return '🎤 Sprachnachricht';
      case MessageType.image:
        return '📷 Bild';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.location:
        return '📍 Standort';
      case MessageType.contact:
        return '👤 Kontakt';
      case MessageType.system:
        return message.content ?? 'System';
    }
  }
  
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    await ref.read(chatProvider.notifier).sendTextMessage(
      conversationId: widget.conversation.id,
      content: text,
      replyToMessageId: _replyToMessage?.id,
    );
    
    _messageController.clear();
    setState(() => _replyToMessage = null);
    _scrollToBottom();
  }
  
  void _setReplyTo(Message message) {
    setState(() => _replyToMessage = message);
  }
  
  void _editMessage(Message message) {
    // TODO: Implement message editing
    _messageController.text = message.content ?? '';
  }
  
  void _deleteMessage(Message message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nachricht löschen'),
        content: const Text('Möchtest du diese Nachricht wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      await ref.read(chatProvider.notifier).deleteMessage(message.id);
    }
  }
  
  void _addReaction(Message message, String emoji) async {
    await ref.read(chatProvider.notifier).addReaction(message.id, emoji);
  }
  
  void _setTypingStatus(bool isTyping) async {
    await ref.read(chatProvider.notifier).setTypingStatus(
      widget.conversation.id,
      isTyping,
    );
  }
  
  void _showConversationInfo() {
    // TODO: Show conversation info sheet
  }
  
  void _makeCall() {
    // TODO: Implement calling feature
    SnackbarUtils.showInfo(context, 'Anrufe kommen bald!');
  }
  
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Suchen'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement search
            },
          ),
          ListTile(
            leading: Icon(
              widget.conversation.isMuted ? Icons.volume_up : Icons.volume_off,
            ),
            title: Text(
              widget.conversation.isMuted ? 'Stummschaltung aufheben' : 'Stummschalten',
            ),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(chatProvider.notifier).toggleMute(
                widget.conversation.id,
                !widget.conversation.isMuted,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archivieren'),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(chatProvider.notifier).toggleArchive(
                widget.conversation.id,
                true,
              );
              if (mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.error),
            title: const Text(
              'Chat löschen',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Chat löschen'),
                  content: const Text(
                    'Möchtest du diesen Chat wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Abbrechen'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Löschen'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && mounted) {
                await ref.read(chatProvider.notifier).deleteConversation(
                  widget.conversation.id,
                );
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}