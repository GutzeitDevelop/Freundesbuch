// Conversations List Page
// 
// Displays all chat conversations with friends and friendbooks
// Version 0.5.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import 'chat_page.dart';
import '../../../friend/presentation/pages/friends_list_page.dart';

/// Page displaying all conversations
class ConversationsListPage extends ConsumerStatefulWidget {
  const ConversationsListPage({super.key});

  @override
  ConsumerState<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends ConsumerState<ConversationsListPage> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Chats'),
            const SizedBox(width: 8),
            // Unread badge in app bar
            unreadCountAsync.when(
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return _buildEmptyState();
          }
          
          final filteredConversations = _filterConversations(conversations);
          
          if (filteredConversations.isEmpty) {
            return _buildNoResultsState();
          }
          
          return ListView.builder(
            itemCount: filteredConversations.length,
            itemBuilder: (context, index) {
              final conversation = filteredConversations[index];
              return _ConversationTile(
                conversation: conversation,
                onTap: () => _openChat(conversation),
                onDelete: () => _deleteConversation(conversation),
                onTogglePin: () => _togglePin(conversation),
                onToggleMute: () => _toggleMute(conversation),
                onToggleArchive: () => _toggleArchive(conversation),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Fehler beim Laden: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(conversationsProvider),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatOptions,
        tooltip: 'Neuer Chat',
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
  
  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Chat mit Freund'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to friends list to select a friend
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendsListPage(selectMode: true),
                ),
              ).then((friend) async {
                if (friend != null) {
                  // Create or get conversation with selected friend
                  final conversation = await ref.read(chatProvider.notifier).createOrGetConversation(
                    friendId: friend.id,
                    friendName: friend.name,
                    friendPhotoPath: friend.photoPath,
                  );
                  
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(conversation: conversation),
                      ),
                    );
                  }
                }
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Gruppen-Chat (Freundesbuch)'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement friendbook group chat selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gruppen-Chats kommen bald!')),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Noch keine Chats',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Starte eine Unterhaltung mit deinen Freunden',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Ergebnisse',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Versuche einen anderen Suchbegriff',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Conversation> _filterConversations(List<Conversation> conversations) {
    if (_searchQuery.isEmpty) {
      return conversations.where((c) => !c.isArchived).toList();
    }
    
    final query = _searchQuery.toLowerCase();
    return conversations.where((c) {
      if (c.isArchived) return false;
      return c.name.toLowerCase().contains(query) ||
             (c.lastMessage?.content?.toLowerCase().contains(query) ?? false);
    }).toList();
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat suchen'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Name oder Nachricht...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
  }
  
  void _openChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(conversation: conversation),
      ),
    );
  }
  
  void _deleteConversation(Conversation conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat löschen'),
        content: Text('Möchtest du den Chat mit ${conversation.name} wirklich löschen?'),
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
      await ref.read(chatProvider.notifier).deleteConversation(conversation.id);
    }
  }
  
  void _togglePin(Conversation conversation) async {
    await ref.read(chatProvider.notifier).togglePin(conversation.id, !conversation.isPinned);
  }
  
  void _toggleMute(Conversation conversation) async {
    await ref.read(chatProvider.notifier).toggleMute(conversation.id, !conversation.isMuted);
  }
  
  void _toggleArchive(Conversation conversation) async {
    await ref.read(chatProvider.notifier).toggleArchive(conversation.id, !conversation.isArchived);
  }
}

/// Individual conversation tile widget
class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleArchive;
  
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.onToggleMute,
    required this.onToggleArchive,
  });
  
  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onTogglePin(),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            icon: conversation.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
            label: conversation.isPinned ? 'Lösen' : 'Anheften',
          ),
          SlidableAction(
            onPressed: (_) => onToggleMute(),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: conversation.isMuted ? Icons.volume_up : Icons.volume_off,
            label: conversation.isMuted ? 'Laut' : 'Stumm',
          ),
          SlidableAction(
            onPressed: (_) => onToggleArchive(),
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archiv',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Löschen',
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: conversation.photoPath != null
                  ? AssetImage(conversation.photoPath!)
                  : null,
              child: conversation.photoPath == null
                  ? Text(
                      conversation.emoji ?? conversation.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),
            // Online indicator
            if (conversation.type == ConversationType.direct &&
                conversation.participants.any((p) => p.isOnline && p.id != 'current_user'))
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            if (conversation.isPinned)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.push_pin, size: 14, color: AppColors.secondary),
              ),
            if (conversation.isMuted)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.volume_off, size: 14, color: Colors.grey),
              ),
            Expanded(
              child: Text(
                conversation.name,
                style: TextStyle(
                  fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(conversation.lastMessage?.timestamp ?? conversation.updatedAt),
              style: TextStyle(
                fontSize: 12,
                color: conversation.unreadCount > 0 ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            if (conversation.lastMessage != null) ...[
              // Message status icon for sent messages
              if (conversation.lastMessage!.senderId == 'current_user') ...[
                Icon(
                  _getStatusIcon(conversation.lastMessage!.status),
                  size: 14,
                  color: conversation.lastMessage!.status == MessageStatus.read
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
              ],
              // Message type icon
              if (conversation.lastMessage!.type != MessageType.text)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    _getMessageTypeIcon(conversation.lastMessage!.type),
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              // Message preview
              Expanded(
                child: Text(
                  _getMessagePreview(conversation.lastMessage!),
                  style: TextStyle(
                    color: conversation.unreadCount > 0 
                        ? AppColors.textPrimary 
                        : AppColors.textSecondary,
                    fontWeight: conversation.unreadCount > 0 
                        ? FontWeight.w500 
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  'Keine Nachrichten',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            // Unread count badge
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
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
  
  IconData _getMessageTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.text_fields;
      case MessageType.voice:
        return Icons.mic;
      case MessageType.image:
        return Icons.image;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.location:
        return Icons.location_on;
      case MessageType.contact:
        return Icons.person;
      case MessageType.system:
        return Icons.info;
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
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Gestern';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'de_DE').format(time);
    } else {
      return DateFormat('dd.MM.yy').format(time);
    }
  }
}