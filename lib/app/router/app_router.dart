import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/core/constants/routes.dart';
import 'package:social_chat_app/features/auth/presentation/screens/login_screen.dart';
//import 'package:social_chat_app/features/auth/presentation/screens/register_screen.dart';
//import 'package:social_chat_app/features/auth/presentation/screens/splash_screen.dart';
//import 'package:social_chat_app/features/home/presentation/screens/home_screen.dart';
import 'package:social_chat_app/features/chat/presentation/screens/chat_screen.dart';
//import 'package:social_chat_app/features/profile/presentation/screens/profile_screen.dart';
//import 'package:social_chat_app/features/posts/presentation/screens/create_post_screen.dart';
//import 'package:social_chat_app/features/posts/presentation/screens/post_detail_screen.dart';
//import 'package:social_chat_app/features/friends/presentation/screens/friends_screen.dart';
//import 'package:social_chat_app/features/friends/presentation/screens/friend_requests_screen.dart';
//import 'package:social_chat_app/features/notifications/presentation/screens/notifications_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
      /*GoRoute(
        path: Routes.splash,
        name: Routes.splash,
        builder: (context, state) => SplashScreen(),
      ),*/
      GoRoute(
        path: Routes.login,
        name: Routes.login,
        builder: (context, state) => LoginScreen(),
      ),
      /*GoRoute(
        path: Routes.register,
        name: Routes.register,
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: Routes.home,
        name: Routes.home,
        builder: (context, state) => HomeScreen(),
      ),*/
      GoRoute(
        path: '${Routes.chat}/:chatId',
        name: Routes.chat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final friendName = state.extra as String? ?? '';
          return ChatScreen(chatId: chatId, friendName: friendName);
        },
      )/*
      GoRoute(
        path: '${Routes.profile}/:userId',
        name: Routes.profile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: Routes.createPost,
        name: Routes.createPost,
        builder: (context, state) => CreatePostScreen(),
      ),
      GoRoute(
        path: '${Routes.postDetail}/:postId',
        name: Routes.postDetail,
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: Routes.friends,
        name: Routes.friends,
        builder: (context, state) => FriendsScreen(),
      ),
      GoRoute(
        path: Routes.friendRequests,
        name: Routes.friendRequests,
        builder: (context, state) => FriendRequestsScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        name: Routes.notifications,
        builder: (context, state) => NotificationsScreen(),
      ),
    ],
    redirect: (context, state) {
      // Add authentication redirect logic here
      return null;
    },
  );*/]);
});