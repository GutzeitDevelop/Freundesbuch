// Chat Repository Implementation
// 
// Concrete implementation of chat repository using Hive
// Version 0.5.0

import 'dart:async';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Implementation of chat repository using in-memory storage
class ChatRepositoryImpl implements ChatRepository {
  static const String _conversationsBoxName = 'conversations';
  static const String _messagesBoxName = 'messages';
  static const String _currentUserId = 'current_user'; // Mock current user ID
  
  // Temporary in-memory storage until Hive adapters are generated
  final Map<String, ConversationModel> _conversationsMap = {};
  final Map<String, MessageModel> _messagesMap = {};
  
  final _uuid = const Uuid();
  final _random = Random();
  
  // Stream controllers
  final _conversationsStreamController = StreamController<List<Conversation>>.broadcast();
  final _messagesStreamController = StreamController<List<Message>>.broadcast();
  final _unreadCountStreamController = StreamController<int>.broadcast();
  final _typingUsersStreamController = StreamController<List<String>>.broadcast();
  
  /// Initialize the repository
  Future<void> init() async {
    // No Hive initialization needed for now
    // Start watching for changes
    _watchConversationsInternal();
    _watchUnreadCountInternal();
  }
  
  // Conversation operations
  
  @override
  Future<List<Conversation>> getAllConversations() async {
    final models = _conversationsMap.values.toList();
    
    // Sort by last message timestamp or creation date
    models.sort((a, b) {
      final aTime = a.lastMessage?.timestamp ?? a.createdAt;
      final bTime = b.lastMessage?.timestamp ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    
    // Sort pinned conversations to top
    models.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<Conversation?> getConversationById(String conversationId) async {
    final model = _conversationsMap[conversationId];
    return model?.toEntity();
  }
  
  @override
  Future<Conversation?> getConversationByFriendId(String friendId) async {
    try {
      final model = _conversationsMap.values.firstWhere(
        (c) => c.friendId == friendId,
      );
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Conversation?> getConversationByFriendBookId(String friendBookId) async {
    try {
      final model = _conversationsMap.values.firstWhere(
        (c) => c.friendBookId == friendBookId,
      );
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Conversation> createOrGetConversation({
    required String friendId,
    required String friendName,
    String? friendPhotoPath,
  }) async {
    // Check if conversation already exists
    final existing = await getConversationByFriendId(friendId);
    if (existing != null) {
      return existing;
    }
    
    // Create new conversation
    final conversationId = _uuid.v4();
    final now = DateTime.now();
    
    final conversation = Conversation(
      id: conversationId,
      type: ConversationType.direct,
      name: friendName,
      photoPath: friendPhotoPath,
      participants: [
        ChatParticipant(
          id: friendId,
          name: friendName,
          photoPath: friendPhotoPath,
          isOnline: _random.nextBool(), // Mock online status
          lastSeen: now.subtract(Duration(minutes: _random.nextInt(60))),
        ),
        ChatParticipant(
          id: _currentUserId,
          name: 'Ich',
          isOnline: true,
        ),
      ],
      createdAt: now,
      updatedAt: now,
      friendId: friendId,
    );
    
    final model = ConversationModel.fromEntity(conversation);
    await _conversationsBox.put(conversationId, model);
    _notifyConversationsChanged();
    
    return conversation;
  }
  
  @override
  Future<Conversation> createGroupConversation({
    required String friendBookId,
    required String friendBookName,
    required List<String> participantIds,
  }) async {
    // Check if conversation already exists
    final existing = await getConversationByFriendBookId(friendBookId);
    if (existing != null) {
      return existing;
    }
    
    // Create new group conversation
    final conversationId = _uuid.v4();
    final now = DateTime.now();
    
    final participants = <ChatParticipant>[
      // Add current user
      const ChatParticipant(
        id: _currentUserId,
        name: 'Ich',
        isOnline: true,
      ),
      // Add other participants (mocked)
      ...participantIds.map((id) => ChatParticipant(
        id: id,
        name: 'Friend $id',
        isOnline: _random.nextBool(),
        lastSeen: now.subtract(Duration(minutes: _random.nextInt(120))),
      )),
    ];
    
    final conversation = Conversation(
      id: conversationId,
      type: ConversationType.group,
      name: friendBookName,
      participants: participants,
      createdAt: now,
      updatedAt: now,
      friendBookId: friendBookId,
      emoji: '📚',
    );
    
    final model = ConversationModel.fromEntity(conversation);
    await _conversationsBox.put(conversationId, model);
    _notifyConversationsChanged();
    
    return conversation;
  }
  
  @override
  Future<void> updateConversation(Conversation conversation) async {
    final model = ConversationModel.fromEntity(conversation);
    await _conversationsBox.put(conversation.id, model);
    _notifyConversationsChanged();
  }
  
  @override
  Future<void> deleteConversation(String conversationId) async {
    // Delete all messages in the conversation
    final messages = _messagesBox.values
        .where((m) => m.conversationId == conversationId)
        .toList();
    for (final message in messages) {
      await message.delete();
    }
    
    // Delete the conversation
    await _conversationsBox.delete(conversationId);
    _notifyConversationsChanged();
  }
  
  @override
  Future<void> toggleArchiveConversation(String conversationId, bool isArchived) async {
    final model = _conversationsBox.get(conversationId);
    if (model != null) {
      final conversation = model.toEntity();
      final updated = conversation.copyWith(isArchived: isArchived);
      await updateConversation(updated);
    }
  }
  
  @override
  Future<void> togglePinConversation(String conversationId, bool isPinned) async {
    final model = _conversationsBox.get(conversationId);
    if (model != null) {
      final conversation = model.toEntity();
      final updated = conversation.copyWith(isPinned: isPinned);
      await updateConversation(updated);
    }
  }
  
  @override
  Future<void> toggleMuteConversation(String conversationId, bool isMuted) async {
    final model = _conversationsBox.get(conversationId);
    if (model != null) {
      final conversation = model.toEntity();
      final updated = conversation.copyWith(isMuted: isMuted);
      await updateConversation(updated);
    }
  }
  
  @override
  Future<void> markConversationAsRead(String conversationId) async {
    final model = _conversationsBox.get(conversationId);
    if (model != null) {
      final conversation = model.toEntity();
      final updated = conversation.copyWith(unreadCount: 0);
      await updateConversation(updated);
      
      // Mark all messages as read
      final messages = _messagesBox.values
          .where((m) => m.conversationId == conversationId && m.senderId != _currentUserId)
          .toList();
      for (final message in messages) {
        if (message.status != MessageStatus.read.index) {
          message.status = MessageStatus.read.index;
          message.readAt = DateTime.now();
          await message.save();
        }
      }
    }
  }
  
  // Message operations
  
  @override
  Future<List<Message>> getMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    final messages = _messagesBox.values
        .where((m) => m.conversationId == conversationId)
        .toList();
    
    // Sort by timestamp
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Apply pagination
    final start = offset;
    final end = min(offset + limit, messages.length);
    
    if (start >= messages.length) {
      return [];
    }
    
    final paginatedMessages = messages.sublist(start, end);
    return paginatedMessages.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<Message?> getMessageById(String messageId) async {
    final model = _messagesBox.get(messageId);
    return model?.toEntity();
  }
  
  @override
  Future<Message> sendMessage(Message message) async {
    // Save message
    final model = MessageModel.fromEntity(message);
    await _messagesBox.put(message.id, model);
    
    // Update conversation's last message and timestamp
    final conversationModel = _conversationsBox.get(message.conversationId);
    if (conversationModel != null) {
      final conversation = conversationModel.toEntity();
      final updated = conversation.copyWith(
        lastMessage: message,
        updatedAt: message.timestamp,
      );
      await updateConversation(updated);
    }
    
    // Simulate message delivery after a delay
    Future.delayed(Duration(seconds: 1 + _random.nextInt(2)), () async {
      await updateMessageStatus(message.id, MessageStatus.delivered);
      
      // Simulate read receipt after another delay
      if (_random.nextBool()) {
        Future.delayed(Duration(seconds: 2 + _random.nextInt(3)), () async {
          await updateMessageStatus(message.id, MessageStatus.read);
        });
      }
    });
    
    _notifyMessagesChanged(message.conversationId);
    return message;
  }
  
  @override
  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    final model = _messagesBox.get(messageId);
    if (model != null) {
      model.status = status.index;
      if (status == MessageStatus.read) {
        model.readAt = DateTime.now();
      }
      await model.save();
      _notifyMessagesChanged(model.conversationId);
    }
  }
  
  @override
  Future<void> deleteMessage(String messageId) async {
    final model = _messagesBox.get(messageId);
    if (model != null) {
      model.isDeleted = true;
      await model.save();
      _notifyMessagesChanged(model.conversationId);
    }
  }
  
  @override
  Future<void> editMessage(String messageId, String newContent) async {
    final model = _messagesBox.get(messageId);
    if (model != null) {
      model.content = newContent;
      model.isEdited = true;
      model.editedAt = DateTime.now();
      await model.save();
      _notifyMessagesChanged(model.conversationId);
    }
  }
  
  @override
  Future<void> addReaction(String messageId, String emoji, String userId) async {
    final model = _messagesBox.get(messageId);
    if (model != null) {
      final reactions = model.reactions ?? {};
      final users = reactions[emoji] ?? [];
      if (!users.contains(userId)) {
        users.add(userId);
        reactions[emoji] = users;
        model.reactions = reactions;
        await model.save();
        _notifyMessagesChanged(model.conversationId);
      }
    }
  }
  
  @override
  Future<void> removeReaction(String messageId, String emoji, String userId) async {
    final model = _messagesBox.get(messageId);
    if (model != null) {
      final reactions = model.reactions ?? {};
      final users = reactions[emoji] ?? [];
      users.remove(userId);
      if (users.isEmpty) {
        reactions.remove(emoji);
      } else {
        reactions[emoji] = users;
      }
      model.reactions = reactions;
      await model.save();
      _notifyMessagesChanged(model.conversationId);
    }
  }
  
  @override
  Future<List<Message>> searchMessages(String query) async {
    final lowerQuery = query.toLowerCase();
    final messages = _messagesBox.values
        .where((m) => 
            m.content?.toLowerCase().contains(lowerQuery) ?? false ||
            m.senderName.toLowerCase().contains(lowerQuery))
        .toList();
    
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.map((m) => m.toEntity()).toList();
  }
  
  // Typing indicators
  
  @override
  Future<void> setTypingStatus(String conversationId, String userId, bool isTyping) async {
    // Mock typing status - in real app this would sync with server
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Simulate other user typing
    if (userId == _currentUserId && _random.nextBool()) {
      Future.delayed(Duration(seconds: 1 + _random.nextInt(2)), () {
        _typingUsersStreamController.add(['Friend']);
        
        // Stop typing after a delay
        Future.delayed(Duration(seconds: 2 + _random.nextInt(3)), () {
          _typingUsersStreamController.add([]);
        });
      });
    }
  }
  
  @override
  Stream<List<String>> getTypingUsers(String conversationId) {
    return _typingUsersStreamController.stream;
  }
  
  // Real-time updates
  
  @override
  Stream<List<Conversation>> watchConversations() {
    return _conversationsStreamController.stream;
  }
  
  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return _messagesStreamController.stream
        .map((messages) => messages.where((m) => 
            m.conversationId == conversationId).toList());
  }
  
  @override
  Stream<int> watchUnreadCount() {
    return _unreadCountStreamController.stream;
  }
  
  // Private helper methods
  
  void _notifyConversationsChanged() async {
    final conversations = await getAllConversations();
    _conversationsStreamController.add(conversations);
    _watchUnreadCountInternal();
  }
  
  void _notifyMessagesChanged(String conversationId) async {
    final messages = await getMessages(conversationId, limit: 100);
    _messagesStreamController.add(messages);
  }
  
  void _watchConversationsInternal() async {
    final conversations = await getAllConversations();
    _conversationsStreamController.add(conversations);
  }
  
  void _watchUnreadCountInternal() async {
    final conversations = await getAllConversations();
    final totalUnread = conversations.fold<int>(
      0, 
      (sum, c) => sum + c.unreadCount,
    );
    _unreadCountStreamController.add(totalUnread);
  }
  
  /// Dispose resources
  void dispose() {
    _conversationsStreamController.close();
    _messagesStreamController.close();
    _unreadCountStreamController.close();
    _typingUsersStreamController.close();
  }
}