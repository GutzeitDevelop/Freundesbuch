// Simple Chat Repository Implementation
// 
// Temporary in-memory implementation for testing
// Version 0.5.2

import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Simple in-memory implementation of chat repository
class SimpleChatRepository implements ChatRepository {
  static const String _currentUserId = 'current_user';
  
  final Map<String, Conversation> _conversations = {};
  final Map<String, Message> _messages = {};
  final Map<String, List<String>> _conversationMessages = {};
  
  final _uuid = const Uuid();
  final _random = Random();
  
  // Stream controllers
  final _conversationsController = StreamController<List<Conversation>>.broadcast();
  final _messagesControllers = <String, StreamController<List<Message>>>{};
  final _unreadCountController = StreamController<int>.broadcast();
  final _typingControllers = <String, StreamController<List<String>>>{};
  
  /// Initialize the repository
  Future<void> init() async {
    // Add some mock data for testing
    _addMockData();
  }
  
  void _addMockData() {
    // Create a test conversation
    final testConvId = _uuid.v4();
    final now = DateTime.now();
    
    final testConv = Conversation(
      id: testConvId,
      type: ConversationType.direct,
      name: 'Test Friend',
      emoji: '👤',
      participants: [
        const ChatParticipant(
          id: 'test_friend',
          name: 'Test Friend',
          isOnline: true,
        ),
        const ChatParticipant(
          id: _currentUserId,
          name: 'Ich',
          isOnline: true,
        ),
      ],
      createdAt: now,
      updatedAt: now,
      friendId: 'test_friend',
    );
    
    _conversations[testConvId] = testConv;
    
    // Add some test messages
    final messages = [
      Message(
        id: _uuid.v4(),
        conversationId: testConvId,
        senderId: 'test_friend',
        senderName: 'Test Friend',
        type: MessageType.text,
        content: 'Hey! Wie geht\'s?',
        status: MessageStatus.read,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      Message(
        id: _uuid.v4(),
        conversationId: testConvId,
        senderId: _currentUserId,
        senderName: 'Ich',
        type: MessageType.text,
        content: 'Gut, danke! Und dir?',
        status: MessageStatus.delivered,
        timestamp: now.subtract(const Duration(minutes: 3)),
      ),
      Message(
        id: _uuid.v4(),
        conversationId: testConvId,
        senderId: 'test_friend',
        senderName: 'Test Friend',
        type: MessageType.text,
        content: 'Auch gut! 😊',
        status: MessageStatus.read,
        timestamp: now.subtract(const Duration(minutes: 1)),
      ),
    ];
    
    for (final msg in messages) {
      _messages[msg.id] = msg;
      _conversationMessages.putIfAbsent(testConvId, () => []).add(msg.id);
    }
    
    // Update conversation with last message
    _conversations[testConvId] = testConv.copyWith(
      lastMessage: messages.last,
      unreadCount: 0,
    );
    
    _notifyConversationsChanged();
  }
  
  @override
  Future<List<Conversation>> getAllConversations() async {
    final convs = _conversations.values.toList();
    convs.sort((a, b) {
      final aTime = a.lastMessage?.timestamp ?? a.createdAt;
      final bTime = b.lastMessage?.timestamp ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return convs;
  }
  
  @override
  Future<Conversation?> getConversationById(String conversationId) async {
    return _conversations[conversationId];
  }
  
  @override
  Future<Conversation?> getConversationByFriendId(String friendId) async {
    try {
      return _conversations.values.firstWhere((c) => c.friendId == friendId);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Conversation?> getConversationByFriendBookId(String friendBookId) async {
    try {
      return _conversations.values.firstWhere((c) => c.friendBookId == friendBookId);
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
          isOnline: _random.nextBool(),
          lastSeen: now.subtract(Duration(minutes: _random.nextInt(60))),
        ),
        const ChatParticipant(
          id: _currentUserId,
          name: 'Ich',
          isOnline: true,
        ),
      ],
      createdAt: now,
      updatedAt: now,
      friendId: friendId,
    );
    
    _conversations[conversationId] = conversation;
    _conversationMessages[conversationId] = [];
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
      const ChatParticipant(
        id: _currentUserId,
        name: 'Ich',
        isOnline: true,
      ),
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
    
    _conversations[conversationId] = conversation;
    _conversationMessages[conversationId] = [];
    _notifyConversationsChanged();
    
    return conversation;
  }
  
  @override
  Future<void> updateConversation(Conversation conversation) async {
    _conversations[conversation.id] = conversation;
    _notifyConversationsChanged();
  }
  
  @override
  Future<void> deleteConversation(String conversationId) async {
    _conversations.remove(conversationId);
    _conversationMessages.remove(conversationId);
    _messages.removeWhere((key, msg) => msg.conversationId == conversationId);
    _notifyConversationsChanged();
  }
  
  @override
  Future<void> toggleArchiveConversation(String conversationId, bool isArchived) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(isArchived: isArchived);
      _notifyConversationsChanged();
    }
  }
  
  @override
  Future<void> togglePinConversation(String conversationId, bool isPinned) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(isPinned: isPinned);
      _notifyConversationsChanged();
    }
  }
  
  @override
  Future<void> toggleMuteConversation(String conversationId, bool isMuted) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(isMuted: isMuted);
      _notifyConversationsChanged();
    }
  }
  
  @override
  Future<void> markConversationAsRead(String conversationId) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(unreadCount: 0);
      _notifyConversationsChanged();
    }
  }
  
  @override
  Future<List<Message>> getMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    final messageIds = _conversationMessages[conversationId] ?? [];
    final messages = messageIds
        .map((id) => _messages[id])
        .whereType<Message>()
        .toList();
    
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    final start = offset;
    final end = min(offset + limit, messages.length);
    
    if (start >= messages.length) {
      return [];
    }
    
    return messages.sublist(start, end);
  }
  
  @override
  Future<Message?> getMessageById(String messageId) async {
    return _messages[messageId];
  }
  
  @override
  Future<Message> sendMessage(Message message) async {
    _messages[message.id] = message;
    _conversationMessages.putIfAbsent(message.conversationId, () => []).add(message.id);
    
    // Update conversation's last message
    final conv = _conversations[message.conversationId];
    if (conv != null) {
      _conversations[message.conversationId] = conv.copyWith(
        lastMessage: message,
        updatedAt: message.timestamp,
      );
      _notifyConversationsChanged();
    }
    
    _notifyMessagesChanged(message.conversationId);
    
    // Simulate message delivery
    Future.delayed(const Duration(seconds: 1), () {
      updateMessageStatus(message.id, MessageStatus.delivered);
    });
    
    return message;
  }
  
  @override
  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    final msg = _messages[messageId];
    if (msg != null) {
      _messages[messageId] = msg.copyWith(
        status: status,
        readAt: status == MessageStatus.read ? DateTime.now() : null,
      );
      _notifyMessagesChanged(msg.conversationId);
    }
  }
  
  @override
  Future<void> deleteMessage(String messageId) async {
    final msg = _messages[messageId];
    if (msg != null) {
      _messages[messageId] = msg.copyWith(isDeleted: true);
      _notifyMessagesChanged(msg.conversationId);
    }
  }
  
  @override
  Future<void> editMessage(String messageId, String newContent) async {
    final msg = _messages[messageId];
    if (msg != null) {
      _messages[messageId] = msg.copyWith(
        content: newContent,
        isEdited: true,
        editedAt: DateTime.now(),
      );
      _notifyMessagesChanged(msg.conversationId);
    }
  }
  
  @override
  Future<void> addReaction(String messageId, String emoji, String userId) async {
    final msg = _messages[messageId];
    if (msg != null) {
      final reactions = Map<String, List<String>>.from(msg.reactions ?? {});
      reactions.putIfAbsent(emoji, () => []).add(userId);
      _messages[messageId] = msg.copyWith(reactions: reactions);
      _notifyMessagesChanged(msg.conversationId);
    }
  }
  
  @override
  Future<void> removeReaction(String messageId, String emoji, String userId) async {
    final msg = _messages[messageId];
    if (msg != null) {
      final reactions = Map<String, List<String>>.from(msg.reactions ?? {});
      reactions[emoji]?.remove(userId);
      if (reactions[emoji]?.isEmpty ?? false) {
        reactions.remove(emoji);
      }
      _messages[messageId] = msg.copyWith(reactions: reactions);
      _notifyMessagesChanged(msg.conversationId);
    }
  }
  
  @override
  Future<List<Message>> searchMessages(String query) async {
    final lowerQuery = query.toLowerCase();
    return _messages.values
        .where((msg) =>
            msg.content?.toLowerCase().contains(lowerQuery) ?? false)
        .toList();
  }
  
  @override
  Future<void> setTypingStatus(String conversationId, String userId, bool isTyping) async {
    // Simulate typing indicator
    final controller = _typingControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<String>>.broadcast(),
    );
    
    if (isTyping && userId == _currentUserId && _random.nextBool()) {
      // Simulate other user typing
      Future.delayed(const Duration(seconds: 1), () {
        controller.add(['Friend']);
        Future.delayed(const Duration(seconds: 3), () {
          controller.add([]);
        });
      });
    }
  }
  
  @override
  Stream<List<String>> getTypingUsers(String conversationId) {
    final controller = _typingControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<String>>.broadcast(),
    );
    return controller.stream;
  }
  
  @override
  Stream<List<Conversation>> watchConversations() {
    // Emit initial conversations immediately
    getAllConversations().then((conversations) {
      _conversationsController.add(conversations);
    });
    
    return _conversationsController.stream;
  }
  
  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final controller = _messagesControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<Message>>.broadcast(),
    );
    
    // Emit initial messages immediately
    getMessages(conversationId, limit: 100).then((messages) {
      controller.add(messages);
    });
    
    return controller.stream;
  }
  
  @override
  Stream<int> watchUnreadCount() {
    // Emit initial count immediately
    getAllConversations().then((conversations) {
      final unreadCount = conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
      _unreadCountController.add(unreadCount);
    });
    
    return _unreadCountController.stream;
  }
  
  void _notifyConversationsChanged() async {
    final convs = await getAllConversations();
    _conversationsController.add(convs);
    
    final unreadCount = convs.fold<int>(0, (sum, c) => sum + c.unreadCount);
    _unreadCountController.add(unreadCount);
  }
  
  void _notifyMessagesChanged(String conversationId) async {
    final controller = _messagesControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<Message>>.broadcast(),
    );
    final messages = await getMessages(conversationId, limit: 100);
    controller.add(messages);
  }
  
  void dispose() {
    _conversationsController.close();
    _unreadCountController.close();
    for (final controller in _messagesControllers.values) {
      controller.close();
    }
    for (final controller in _typingControllers.values) {
      controller.close();
    }
  }
}