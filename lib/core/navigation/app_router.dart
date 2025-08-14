// App navigation configuration
// 
// Manages routing between screens using GoRouter

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/friend/presentation/pages/add_friend_page.dart';
import '../../features/friend/presentation/pages/friends_list_page.dart';
import '../../features/friend/presentation/pages/friend_detail_page.dart';
import '../../features/friendbook/presentation/pages/friend_books_list_page.dart';
import '../../features/friendbook/presentation/pages/friend_book_detail_page.dart';
import '../../features/template/presentation/pages/template_management_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_view_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/chat/presentation/pages/conversations_list_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/domain/entities/conversation.dart';

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// App navigation routes
class AppRouter {
  static const String home = '/';
  static const String friendsList = '/friends';
  static const String addFriend = '/friends/add';
  static const String friendDetail = '/friends/:id';
  static const String editFriend = '/friends/:id/edit';
  static const String friendBooksList = '/friendbooks';
  static const String friendBookDetail = '/friendbooks/:id';
  static const String templateManagement = '/templates';
  static const String profileView = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String mapView = '/map';
  static const String conversationsList = '/chats';
  static const String chatPage = '/chats/:id';
  
  /// Main router configuration
  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // Home page
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      // Friends list
      GoRoute(
        path: friendsList,
        name: 'friendsList',
        builder: (context, state) => const FriendsListPage(),
        routes: [
          // Add friend
          GoRoute(
            path: 'add',
            name: 'addFriend',
            builder: (context, state) => const AddFriendPage(),
          ),
          
          // Friend detail
          GoRoute(
            path: ':id',
            name: 'friendDetail',
            builder: (context, state) {
              final friendId = state.pathParameters['id']!;
              return FriendDetailPage(friendId: friendId);
            },
            routes: [
              // Edit friend
              GoRoute(
                path: 'edit',
                name: 'editFriend',
                builder: (context, state) {
                  final friendId = state.pathParameters['id']!;
                  return AddFriendPage(friendId: friendId);
                },
              ),
            ],
          ),
        ],
      ),
      
      // FriendBooks list
      GoRoute(
        path: friendBooksList,
        name: 'friendBooksList',
        builder: (context, state) => const FriendBooksListPage(),
        routes: [
          // FriendBook detail
          GoRoute(
            path: ':id',
            name: 'friendBookDetail',
            builder: (context, state) {
              final bookId = state.pathParameters['id']!;
              return FriendBookDetailPage(friendBookId: bookId);
            },
          ),
        ],
      ),
      
      // Template management
      GoRoute(
        path: templateManagement,
        name: 'templateManagement',
        builder: (context, state) => const TemplateManagementPage(),
      ),
      
      // Profile
      GoRoute(
        path: profileView,
        name: 'profileView',
        builder: (context, state) => const ProfileViewPage(),
        routes: [
          // Edit profile
          GoRoute(
            path: 'edit',
            name: 'profileEdit',
            builder: (context, state) {
              final profile = state.extra;
              return ProfileEditPage(existingProfile: profile as UserProfile?);
            },
          ),
        ],
      ),
      
      // Map view
      GoRoute(
        path: mapView,
        name: 'mapView',
        builder: (context, state) => const MapPage(),
      ),
      
      // Conversations list
      GoRoute(
        path: conversationsList,
        name: 'conversationsList',
        builder: (context, state) => const ConversationsListPage(),
        routes: [
          // Individual chat
          GoRoute(
            path: ':id',
            name: 'chatPage',
            builder: (context, state) {
              final conversation = state.extra as Conversation;
              return ChatPage(conversation: conversation);
            },
          ),
        ],
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}