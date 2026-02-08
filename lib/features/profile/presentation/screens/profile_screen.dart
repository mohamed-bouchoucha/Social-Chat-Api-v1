import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_chat_app/shared/providers/providers.dart';
import 'package:social_chat_app/shared/repositories/user_repository.dart';
import 'package:social_chat_app/shared/models/user.dart';
import 'package:social_chat_app/shared/models/friend_request.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';

/// Provider for fetching user profile by ID
final userProfileProvider = FutureProvider.family<User, int>((ref, userId) async {
  final repo = ref.read(userRepositoryProvider);
  return repo.getUserById(userId);
});

class ProfileScreen extends ConsumerWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwnProfile = currentUser?.id == userId;
    final userAsync = isOwnProfile 
        ? AsyncValue.data(currentUser!)
        : ref.watch(userProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!isOwnProfile)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'block',
                  child: Text('Block User'),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Text('Report'),
                ),
              ],
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(userProfileProvider(userId)),
        ),
        data: (user) => _ProfileContent(
          user: user,
          isOwnProfile: isOwnProfile,
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final User user;
  final bool isOwnProfile;

  const _ProfileContent({
    required this.user,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationshipAsync = isOwnProfile 
        ? null 
        : ref.watch(relationshipProvider(user.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          AvatarWidget(
            imageUrl: user.avatarUrl,
            name: user.name,
            size: 100,
            showOnlineIndicator: true,
            isOnline: user.isOnline,
          ),
          const SizedBox(height: 16),

          // Name and username
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

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          if (isOwnProfile)
            OutlinedButton.icon(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            )
          else if (relationshipAsync != null)
            relationshipAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
              data: (relationship) => _buildActionButtons(context, ref, relationship),
            ),

          const SizedBox(height: 32),

          // Stats (optional)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(label: 'Posts', value: '0'),
              _StatItem(label: 'Friends', value: '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Relationship relationship) {
    if (relationship.isFriends) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final conversation = await ref
                  .read(conversationsProvider.notifier)
                  .createOrGetConversation([user.id]);
              if (context.mounted) {
                context.push('/chat/${conversation.id}');
              }
            },
            icon: const Icon(Icons.message),
            label: const Text('Message'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () async {
              await ref.read(friendsProvider.notifier).removeFriend(user.id);
            },
            child: const Text('Unfriend'),
          ),
        ],
      );
    }

    if (relationship.requestSent) {
      return OutlinedButton(
        onPressed: null,
        child: const Text('Request Sent'),
      );
    }

    if (relationship.requestReceived) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              // Accept request
              await ref.read(friendsProvider.notifier).acceptRequest(relationship.requestId ?? 0);
            },
            child: const Text('Accept'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () async {
              // Reject request
              await ref.read(friendsProvider.notifier).rejectRequest(relationship.requestId ?? 0);
            },
            child: const Text('Reject'),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: () async {
        await ref.read(friendsProvider.notifier).sendRequest(user.id);
      },
      icon: const Icon(Icons.person_add),
      label: const Text('Add Friend'),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
