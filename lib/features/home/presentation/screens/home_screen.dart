import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_chat_app/shared/providers/providers.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';
import 'package:social_chat_app/features/posts/presentation/widgets/post_card.dart';
import 'package:social_chat_app/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:social_chat_app/features/friends/presentation/widgets/friend_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).loadFeed();
      ref.read(conversationsProvider.notifier).loadConversations();
      ref.read(friendsProvider.notifier).loadAll();
      ref.read(notificationsProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadMessages = ref.watch(unreadMessagesCountProvider);
    final pendingRequests = ref.watch(pendingRequestsCountProvider);
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _FeedTab(),
          _ChatsTab(),
          _FriendsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadMessages > 0,
              label: Text('$unreadMessages'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: unreadMessages > 0,
              label: Text('$unreadMessages'),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingRequests > 0,
              label: Text('$pendingRequests'),
              child: const Icon(Icons.people_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingRequests > 0,
              label: Text('$pendingRequests'),
              child: const Icon(Icons.people),
            ),
            label: 'Friends',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push('/create-post'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  AppBar _buildAppBar() {
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    
    return AppBar(
      title: Text(_getTitle()),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push('/search'),
        ),
        IconButton(
          icon: Badge(
            isLabelVisible: unreadNotifications > 0,
            label: Text('$unreadNotifications'),
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () => context.push('/notifications'),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Feed';
      case 1:
        return 'Chats';
      case 2:
        return 'Friends';
      case 3:
        return 'Profile';
      default:
        return 'Social Chat';
    }
  }
}

/// Feed Tab - Shows posts
class _FeedTab extends ConsumerWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    if (feedState.isLoading && feedState.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feedState.error != null && feedState.posts.isEmpty) {
      return ErrorView(
        message: feedState.error!,
        onRetry: () => ref.read(feedProvider.notifier).loadFeed(),
      );
    }

    if (feedState.posts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.article_outlined,
        title: 'No posts yet',
        subtitle: 'Be the first to share something!',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: feedState.posts.length + (feedState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= feedState.posts.length) {
            // Load more trigger
            if (!feedState.isLoadingMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(feedProvider.notifier).loadMore();
              });
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final post = feedState.posts[index];
          return PostCard(
            post: post,
            onTap: () => context.push('/post/${post.id}'),
            onLike: () => ref.read(feedProvider.notifier).toggleLike(post.id),
            onComment: () => context.push('/post/${post.id}'),
          );
        },
      ),
    );
  }
}

/// Chats Tab - Shows conversations
class _ChatsTab extends ConsumerWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsState = ref.watch(conversationsProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (conversationsState.isLoading && conversationsState.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (conversationsState.error != null && conversationsState.conversations.isEmpty) {
      return ErrorView(
        message: conversationsState.error!,
        onRetry: () => ref.read(conversationsProvider.notifier).loadConversations(),
      );
    }

    if (conversationsState.conversations.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.chat_bubble_outline,
        title: 'No conversations',
        subtitle: 'Start chatting with your friends!',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(conversationsProvider.notifier).loadConversations(),
      child: ListView.builder(
        itemCount: conversationsState.conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversationsState.conversations[index];
          return ConversationTile(
            conversation: conversation,
            currentUserId: currentUser?.id ?? 0,
            onTap: () => context.push('/chat/${conversation.id}'),
          );
        },
      ),
    );
  }
}

/// Friends Tab - Shows friends list and requests
class _FriendsTab extends ConsumerWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(friendsProvider);

    if (friendsState.isLoading && friendsState.friends.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friendsState.error != null && friendsState.friends.isEmpty) {
      return ErrorView(
        message: friendsState.error!,
        onRetry: () => ref.read(friendsProvider.notifier).loadAll(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(friendsProvider.notifier).loadAll(),
      child: CustomScrollView(
        slivers: [
          // Friend requests section
          if (friendsState.receivedRequests.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: ListTile(
                leading: const Icon(Icons.person_add),
                title: Text('Friend Requests (${friendsState.receivedRequests.length})'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/friend-requests'),
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
          ],

          // Friends list
          if (friendsState.friends.isEmpty)
            const SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.people_outline,
                title: 'No friends yet',
                subtitle: 'Search for people to connect with',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final friend = friendsState.friends[index];
                  return FriendTile(
                    friend: friend,
                    onTap: () => context.push('/profile/${friend.user.id}'),
                    onMessage: () async {
                      final conversation = await ref
                          .read(conversationsProvider.notifier)
                          .createOrGetConversation([friend.user.id]);
                      if (context.mounted) {
                        context.push('/chat/${conversation.id}');
                      }
                    },
                  );
                },
                childCount: friendsState.friends.length,
              ),
            ),
        ],
      ),
    );
  }
}

/// Profile Tab - Shows current user profile
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDarkMode = ref.watch(isDarkModeProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          AvatarWidget(
            imageUrl: user.avatarUrl,
            name: user.name,
            size: 100,
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],

          const SizedBox(height: 24),

          // Edit profile button
          OutlinedButton.icon(
            onPressed: () => context.push('/edit-profile'),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),

          const SizedBox(height: 32),

          // Settings section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to change password
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red.shade400),
                  title: Text('Logout', style: TextStyle(color: Colors.red.shade400)),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(authProvider.notifier).logout();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}