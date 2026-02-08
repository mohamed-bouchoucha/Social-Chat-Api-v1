import 'package:flutter/material.dart';
import 'package:social_chat_app/shared/models/post.dart';
import 'package:social_chat_app/shared/widgets/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Post card widget for displaying posts in the feed
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  AvatarWidget(
                    imageUrl: post.author.avatarUrl,
                    name: post.author.name,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          post.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_horiz),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('Report'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              // Images
              if (post.hasImages) ...[
                const SizedBox(height: 12),
                _buildImages(context),
              ],

              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  if (post.likesCount > 0)
                    Text(
                      '${post.likesCount} likes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  if (post.likesCount > 0 && post.commentsCount > 0)
                    Text(
                      ' • ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  if (post.commentsCount > 0)
                    Text(
                      '${post.commentsCount} comments',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),

              const Divider(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionButton(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: 'Like',
                    isActive: post.isLiked,
                    onTap: onLike,
                  ),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comment',
                    onTap: onComment,
                  ),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: onShare,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImages(BuildContext context) {
    if (post.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: post.imageUrls.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Theme.of(context).colorScheme.surface,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Theme.of(context).colorScheme.surface,
            child: const Icon(Icons.error),
          ),
        ),
      );
    }

    // Multiple images grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: post.imageUrls.length > 4 ? 4 : post.imageUrls.length,
      itemBuilder: (context, index) {
        final isLast = index == 3 && post.imageUrls.length > 4;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: post.imageUrls[index],
                fit: BoxFit.cover,
              ),
              if (isLast)
                Container(
                  color: Colors.black45,
                  child: Center(
                    child: Text(
                      '+${post.imageUrls.length - 4}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
