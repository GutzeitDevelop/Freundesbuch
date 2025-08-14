// Chat Provider
// 
// State management for chat functionality
// Version 0.5.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';

/// Provider for chat repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repository = ChatRepositoryImpl();
  repository.init();
  return repository;
});

/// Provider for all conversations
final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchConversations();
});

/// Provider for a specific conversation
final conversationProvider = FutureProvider.family<Conversation?, String>((ref, conversationId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getConversationById(conversationId);
});

/// Provider for messages in a conversation
final messagesProvider = StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(conversationId);
});

/// Provider for unread message count
final unreadCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchUnreadCount();
});

/// Provider for typing users in a conversation
final typingUsersProvider = StreamProvider.family<List<String>, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getTypingUsers(conversationId);
});

/// State notifier for managing chat actions
class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;
  final _uuid = const Uuid();
  
  ChatNotifier(this._repository) : super(const AsyncValue.data(null));
  
  /// Create or get conversation with a friend
  Future<Conversation> createOrGetConversation({
    required String friendId,
    required String friendName,
    String? friendPhotoPath,
  }) async {
    state = const AsyncValue.loading();
    try {
      final conversation = await _repository.createOrGetConversation(
        friendId: friendId,
        friendName: friendName,
        friendPhotoPath: friendPhotoPath,
      );
      state = const AsyncValue.data(null);
      return conversation;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Create group conversation for friendbook
  Future<Conversation> createGroupConversation({
    required String friendBookId,
    required String friendBookName,
    required List<String> participantIds,
  }) async {
    state = const AsyncValue.loading();
    try {
      final conversation = await _repository.createGroupConversation(
        friendBookId: friendBookId,
        friendBookName: friendBookName,
        participantIds: participantIds,
      );
      state = const AsyncValue.data(null);
      return conversation;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Send a text message
  Future<void> sendTextMessage({
    required String conversationId,
    required String content,
    String? replyToMessageId,
  }) async {
    if (content.trim().isEmpty) return;
    
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: 'current_user',
      senderName: 'Ich',
      type: MessageType.text,
      content: content.trim(),
      replyToMessageId: replyToMessageId,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );
    
    await _repository.sendMessage(message);
  }
  
  /// Send a voice message
  Future<void> sendVoiceMessage({
    required String conversationId,
    required String filePath,
    required int duration,
  }) async {
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: 'current_user',
      senderName: 'Ich',
      type: MessageType.voice,
      filePath: filePath,
      duration: duration,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );
    
    await _repository.sendMessage(message);
  }
  
  /// Send an image message
  Future<void> sendImageMessage({
    required String conversationId,
    required String filePath,
  }) async {
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: 'current_user',
      senderName: 'Ich',
      type: MessageType.image,
      filePath: filePath,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );
    
    await _repository.sendMessage(message);
  }
  
  /// Send a location message
  Future<void> sendLocationMessage({
    required String conversationId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: 'current_user',
      senderName: 'Ich',
      type: MessageType.location,
      location: (latitude, longitude),
      locationAddress: address,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );
    
    await _repository.sendMessage(message);
  }
  
  /// Mark conversation as read
  Future<void> markAsRead(String conversationId) async {
    await _repository.markConversationAsRead(conversationId);
  }
  
  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _repository.deleteMessage(messageId);
  }
  
  /// Edit a message
  Future<void> editMessage(String messageId, String newContent) async {
    await _repository.editMessage(messageId, newContent);
  }
  
  /// Add reaction to message
  Future<void> addReaction(String messageId, String emoji) async {
    await _repository.addReaction(messageId, emoji, 'current_user');
  }
  
  /// Remove reaction from message
  Future<void> removeReaction(String messageId, String emoji) async {
    await _repository.removeReaction(messageId, emoji, 'current_user');
  }
  
  /// Toggle archive status
  Future<void> toggleArchive(String conversationId, bool isArchived) async {
    await _repository.toggleArchiveConversation(conversationId, isArchived);
  }
  
  /// Toggle pin status
  Future<void> togglePin(String conversationId, bool isPinned) async {
    await _repository.togglePinConversation(conversationId, isPinned);
  }
  
  /// Toggle mute status
  Future<void> toggleMute(String conversationId, bool isMuted) async {
    await _repository.toggleMuteConversation(conversationId, isMuted);
  }
  
  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    await _repository.deleteConversation(conversationId);
  }
  
  /// Set typing status
  Future<void> setTypingStatus(String conversationId, bool isTyping) async {
    await _repository.setTypingStatus(conversationId, 'current_user', isTyping);
  }
  
  /// Search messages
  Future<List<Message>> searchMessages(String query) async {
    return _repository.searchMessages(query);
  }
}

/// Provider for chat notifier
final chatProvider = StateNotifierProvider<ChatNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});