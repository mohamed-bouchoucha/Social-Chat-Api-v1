import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/shared/providers/auth_provider.dart';

// Import screens
import 'package:social_chat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:social_chat_app/features/auth/presentation/screens/register_screen.dart';
import 'package:social_chat_app/features/home/presentation/screens/home_screen.dart';
import 'package:social_chat_app/features/posts/presentation/screens/create_post_screen.dart';
import 'package:social_chat_app/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:social_chat_app/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:social_chat_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:social_chat_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:social_chat_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:social_chat_app/features/friends/presentation/screens/friend_requests_screen.dart';
import 'package:social_chat_app/features/friends/presentation/screens/user_search_screen.dart';

/// Route names
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createPost = '/create-post';
  static const String postDetail = '/post/:id';
  static const String chatRoom = '/chat/:id';
  static const String profile = '/profile/:id';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String friendRequests = '/friend-requests';
  static const String userSearch = '/search';
}

/// GoRouter provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == Routes.login;
      final isRegistering = state.matchedLocation == Routes.register;
      final isSplash = state.matchedLocation == Routes.splash;

      // If still loading auth state, stay on splash
      if (authState.status == AuthStatus.initial || 
          authState.status == AuthStatus.loading) {
        return isSplash ? null : Routes.splash;
      }

      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return Routes.login;
      }

      // If logged in and on auth pages, redirect to home
      if (isLoggedIn && (isLoggingIn || isRegistering || isSplash)) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      // Splash/Loading
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app routes
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Post routes
      GoRoute(
        path: Routes.createPost,
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: Routes.postDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PostDetailScreen(postId: id);
        },
      ),

      // Chat routes
      GoRoute(
        path: Routes.chatRoom,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatRoomScreen(conversationId: id);
        },
      ),

      // Profile routes
      GoRoute(
        path: Routes.profile,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Other routes
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.friendRequests,
        builder: (context, state) => const FriendRequestsScreen(),
      ),
      GoRoute(
        path: Routes.userSearch,
        builder: (context, state) => const UserSearchScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri.path}'),
      ),
    ),
  );
});

/// Simple splash screen while checking auth
class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth status on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Social Chat',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
