import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/shared/repositories/friend_repository.dart';
import 'package:social_chat_app/shared/models/user.dart';
import 'package:social_chat_app/shared/models/friend_request.dart';

/// Friends state
class FriendsState {
  final List<Friend> friends;
  final List<FriendRequest> receivedRequests;
  final List<FriendRequest> sentRequests;
  final bool isLoading;
  final String? error;

  const FriendsState({
    this.friends = const [],
    this.receivedRequests = const [],
    this.sentRequests = const [],
    this.isLoading = false,
    this.error,
  });

  FriendsState copyWith({
    List<Friend>? friends,
    List<FriendRequest>? receivedRequests,
    List<FriendRequest>? sentRequests,
    bool? isLoading,
    String? error,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get pendingRequestsCount => receivedRequests.length;
}

/// Friends notifier
class FriendsNotifier extends StateNotifier<FriendsState> {
  final FriendRepository _friendRepository;

  FriendsNotifier(this._friendRepository) : super(const FriendsState());

  /// Load all friends data
  Future<void> loadAll() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final results = await Future.wait([
        _friendRepository.getFriends(),
        _friendRepository.getReceivedRequests(),
        _friendRepository.getSentRequests(),
      ]);
      
      state = state.copyWith(
        friends: results[0].content as List<Friend>,
        receivedRequests: results[1].content as List<FriendRequest>,
        sentRequests: results[2].content as List<FriendRequest>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Send friend request
  Future<void> sendRequest(int userId) async {
    final request = await _friendRepository.sendRequest(userId);
    state = state.copyWith(
      sentRequests: [...state.sentRequests, request],
    );
  }

  /// Accept friend request
  Future<void> acceptRequest(int requestId) async {
    await _friendRepository.acceptRequest(requestId);
    
    // Find the request and move to friends
    final request = state.receivedRequests.firstWhere((r) => r.id == requestId);
    state = state.copyWith(
      receivedRequests: state.receivedRequests.where((r) => r.id != requestId).toList(),
      friends: [
        ...state.friends,
        Friend(id: requestId, user: request.sender, friendsSince: DateTime.now()),
      ],
    );
  }

  /// Reject friend request
  Future<void> rejectRequest(int requestId) async {
    await _friendRepository.rejectRequest(requestId);
    state = state.copyWith(
      receivedRequests: state.receivedRequests.where((r) => r.id != requestId).toList(),
    );
  }

  /// Remove friend
  Future<void> removeFriend(int friendId) async {
    await _friendRepository.removeFriend(friendId);
    state = state.copyWith(
      friends: state.friends.where((f) => f.id != friendId).toList(),
    );
  }

  /// Block user
  Future<void> blockUser(int userId) async {
    await _friendRepository.blockUser(userId);
    state = state.copyWith(
      friends: state.friends.where((f) => f.user.id != userId).toList(),
    );
  }
}

/// Friend repository provider
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository();
});

/// Friends provider
final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  final repo = ref.watch(friendRepositoryProvider);
  return FriendsNotifier(repo);
});

/// Just friends list
final friendsListProvider = Provider<List<Friend>>((ref) {
  return ref.watch(friendsProvider).friends;
});

/// Pending requests count
final pendingRequestsCountProvider = Provider<int>((ref) {
  return ref.watch(friendsProvider).pendingRequestsCount;
});

/// Relationship status provider
final relationshipProvider = FutureProvider.family<Relationship, int>((ref, userId) async {
  final repo = ref.watch(friendRepositoryProvider);
  return repo.getRelationship(userId);
});
