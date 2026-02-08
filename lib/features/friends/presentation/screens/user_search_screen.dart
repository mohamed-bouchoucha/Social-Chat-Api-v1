import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_chat_app/shared/repositories/search_repository.dart';
import 'package:social_chat_app/shared/models/user.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';

/// Search state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results provider
final searchResultsProvider = FutureProvider<List<User>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final repo = SearchRepository();
  final response = await repo.searchUsers(query);
  return response.content;
});

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Search for users by name or username'),
                ],
              ),
            )
          : searchResults.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
              data: (users) => users.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.person_search,
                      title: 'No users found',
                      subtitle: 'Try a different search term',
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: AvatarWidget(
                            imageUrl: user.avatarUrl,
                            name: user.name,
                            size: 48,
                            showOnlineIndicator: true,
                            isOnline: user.isOnline,
                          ),
                          title: Text(user.name),
                          subtitle: Text('@${user.username}'),
                          onTap: () => context.push('/profile/${user.id}'),
                        );
                      },
                    ),
            ),
    );
  }
}

/// Simple debouncer utility
class Debouncer {
  final int milliseconds;
  VoidCallback? _action;
  bool _disposed = false;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_disposed) return;
    _action = action;
    Future.delayed(Duration(milliseconds: milliseconds), () {
      if (!_disposed && _action != null) {
        _action!();
        _action = null;
      }
    });
  }

  void dispose() {
    _disposed = true;
    _action = null;
  }
}
