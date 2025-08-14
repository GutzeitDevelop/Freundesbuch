// Chat Repository Interface
// 
// Defines the contract for chat-related operations
// Version 0.5.0

import '../entities/conversation.dart';
import '../entities/message.dart';

/// Repository interface for chat operations
abstract class ChatRepository {
  // Conversation operations
  
  /// Get all conversations
  Future<List<Conversation>> getAllConversations();
  
  /// Get conversation by ID
  Future<Conversation?> getConversationById(String conversationId);
  
  /// Get conversation for a friend
  Future<Conversation?> getConversationByFriendId(String friendId);
  
  /// Get conversation for a friendbook
  Future<Conversation?> getConversationByFriendBookId(String friendBookId);
  
  /// Create or get existing conversation
  Future<Conversation> createOrGetConversation({
    required String friendId,
    required String friendName,
    String? friendPhotoPath,
  });
  
  /// Create group conversation for friendbook
  Future<Conversation> createGroupConversation({
    required String friendBookId,
    required String friendBookName,
    required List<String> participantIds,
  });
  
  /// Update conversation
  Future<void> updateConversation(Conversation conversation);
  
  /// Delete conversation
  Future<void> deleteConversation(String conversationId);
  
  /// Archive/unarchive conversation
  Future<void> toggleArchiveConversation(String conversationId, bool isArchived);
  
  /// Pin/unpin conversation
  Future<void> togglePinConversation(String conversationId, bool isPinned);
  
  /// Mute/unmute conversation
  Future<void> toggleMuteConversation(String conversationId, bool isMuted);
  
  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId);
  
  // Message operations
  
  /// Get messages for a conversation
  Future<List<Message>> getMessages(String conversationId, {int limit = 50, int offset = 0});
  
  /// Get message by ID
  Future<Message?> getMessageById(String messageId);
  
  /// Send a message
  Future<Message> sendMessage(Message message);
  
  /// Update message status
  Future<void> updateMessageStatus(String messageId, MessageStatus status);
  
  /// Delete a message
  Future<void> deleteMessage(String messageId);
  
  /// Edit a message
  Future<void> editMessage(String messageId, String newContent);
  
  /// Add reaction to message
  Future<void> addReaction(String messageId, String emoji, String userId);
  
  /// Remove reaction from message
  Future<void> removeReaction(String messageId, String emoji, String userId);
  
  /// Search messages
  Future<List<Message>> searchMessages(String query);
  
  // Typing indicators
  
  /// Set typing status
  Future<void> setTypingStatus(String conversationId, String userId, bool isTyping);
  
  /// Get typing users for conversation
  Stream<List<String>> getTypingUsers(String conversationId);
  
  // Real-time updates
  
  /// Stream of conversation updates
  Stream<List<Conversation>> watchConversations();
  
  /// Stream of messages for a conversation
  Stream<List<Message>> watchMessages(String conversationId);
  
  /// Stream of unread count
  Stream<int> watchUnreadCount();
}