import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/shared/repositories/post_repository.dart';
import 'package:social_chat_app/shared/models/post.dart';
import 'package:social_chat_app/core/network/api_response.dart';

/// Feed state
class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

/// Feed notifier for managing posts feed
class FeedNotifier extends StateNotifier<FeedState> {
  final PostRepository _postRepository;

  FeedNotifier(this._postRepository) : super(const FeedState());

  /// Load initial feed
  Future<void> loadFeed() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final pageResponse = await _postRepository.getFeed(page: 0);
      state = state.copyWith(
        posts: pageResponse.content,
        isLoading: false,
        hasMore: pageResponse.hasMore,
        currentPage: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    
    state = state.copyWith(isLoadingMore: true);
    
    try {
      final nextPage = state.currentPage + 1;
      final pageResponse = await _postRepository.getFeed(page: nextPage);
      state = state.copyWith(
        posts: [...state.posts, ...pageResponse.content],
        isLoadingMore: false,
        hasMore: pageResponse.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Refresh feed (pull to refresh)
  Future<void> refresh() async {
    state = state.copyWith(error: null);
    
    try {
      final pageResponse = await _postRepository.getFeed(page: 0);
      state = state.copyWith(
        posts: pageResponse.content,
        hasMore: pageResponse.hasMore,
        currentPage: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Create a new post
  Future<Post> createPost(String content, {List<String>? imagePaths}) async {
    final post = await _postRepository.createPost(
      content: content,
      imagePaths: imagePaths,
    );
    // Add to beginning of feed
    state = state.copyWith(posts: [post, ...state.posts]);
    return post;
  }

  /// Toggle like on a post
  Future<void> toggleLike(int postId) async {
    final postIndex = state.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;
    
    final post = state.posts[postIndex];
    final wasLiked = post.isLiked;
    
    // Optimistic update
    final updatedPost = post.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    final updatedPosts = [...state.posts];
    updatedPosts[postIndex] = updatedPost;
    state = state.copyWith(posts: updatedPosts);
    
    try {
      if (wasLiked) {
        await _postRepository.unlikePost(postId);
      } else {
        await _postRepository.likePost(postId);
      }
    } catch (e) {
      // Rollback on error
      final rollbackPosts = [...state.posts];
      rollbackPosts[postIndex] = post;
      state = state.copyWith(posts: rollbackPosts);
    }
  }

  /// Delete a post
  Future<void> deletePost(int postId) async {
    await _postRepository.deletePost(postId);
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }

  /// Update post in feed
  void updatePost(Post updatedPost) {
    final posts = state.posts.map((p) {
      return p.id == updatedPost.id ? updatedPost : p;
    }).toList();
    state = state.copyWith(posts: posts);
  }
}

/// Post repository provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

/// Feed provider
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return FeedNotifier(repo);
});

/// Single post provider
final postProvider = FutureProvider.family<Post, int>((ref, postId) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getPost(postId);
});

/// User posts provider
final userPostsProvider = FutureProvider.family<PageResponse<Post>, int>((ref, userId) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getUserPosts(userId);
});
