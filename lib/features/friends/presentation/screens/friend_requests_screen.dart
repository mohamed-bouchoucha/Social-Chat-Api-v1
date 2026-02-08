import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/shared/providers/friends_provider.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';

class FriendRequestsScreen extends ConsumerWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(friendsProvider);
    final receivedRequests = friendsState.receivedRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: friendsState.isLoading && receivedRequests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : receivedRequests.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.person_add_disabled,
                  title: 'No pending requests',
                  subtitle: 'New friend requests will appear here',
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(friendsProvider.notifier).loadAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: receivedRequests.length,
                    itemBuilder: (context, index) {
                      final request = receivedRequests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              AvatarWidget(
                                imageUrl: request.sender.avatarUrl,
                                name: request.sender.name,
                                size: 52,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.sender.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '@${request.sender.username}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      ref.read(friendsProvider.notifier).acceptRequest(request.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(80, 36),
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      ref.read(friendsProvider.notifier).rejectRequest(request.id);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(80, 36),
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
