import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../../profile/providers/profile_provider.dart';
import 'post_form_bottom_sheet.dart';
import 'delete_post_dialog.dart';
import '../../../core/widgets/app_popup_menu.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  final bool isDetailView;

  const PostCard({
    super.key,
    required this.post,
    this.isDetailView = false,
  });

  Future<void> _handleDeletePost(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const DeletePostDialog(),
    );
    
    if (confirm == true) {
      try {
        await ref.read(postProvider.notifier).deletePost(post.id);
        
        ref.read(postProvider.notifier).loadPosts();
        ref.read(profileProvider.notifier).loadProfileData();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa bài đăng')),
          );
          if (isDetailView) {
            context.pop();
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: isDetailView ? null : () => context.push('/post/${post.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: isDetailView ? 0 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDetailView ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isDetailView ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Time, Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (post.isMine) {
                        context.go('/profile');
                      } else {
                        context.push('/user/${post.authorId}');
                      }
                    },
                    child: AppAvatar(
                      imageUrl: post.authorAvatar,
                      radius: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (post.isMine) {
                              context.go('/profile');
                            } else {
                              context.push('/user/${post.authorId}');
                            }
                          },
                          child: Text(
                            post.authorName,
                            style: AppTextStyles.heading3.copyWith(fontSize: 15),
                          ),
                        ),
                        Text(
                          post.timeAgo,
                          style: AppTextStyles.bodyGrey.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (post.isMine)
                    AppPopupMenu(
                      onSelected: (val) {
                        if (val == 'edit') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => PostFormBottomSheet(post: post),
                          );
                        } else if (val == 'delete') {
                          _handleDeletePost(context, ref);
                        }
                      },
                      items: const [
                        AppPopupMenuItemData(value: 'edit', icon: Icons.edit_outlined, label: 'Sửa', color: Colors.blue),
                        AppPopupMenuItemData(value: 'delete', icon: Icons.delete_outline, label: 'Xóa', color: Colors.red, isDestructive: true),
                      ],
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),

            // Image (if any)
            if (post.imageUrls.isNotEmpty)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                child: _buildImageGallery(post.imageUrls),
              ),

            // Actions: Like, Comment
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Like
                  GestureDetector(
                    onTap: () {
                      ref.read(postProvider.notifier).toggleLike(post.id).catchError((e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                        }
                      });
                    },
                    child: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? AppColors.error : AppColors.textDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likeCount}',
                    style: AppTextStyles.heading3.copyWith(fontSize: 15),
                  ),
                  const SizedBox(width: 20),

                  // Comment
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.textDark,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentCount}',
                    style: AppTextStyles.heading3.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    return _ImageCarousel(imageUrls: imageUrls);
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageCarousel({required this.imageUrls});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.length == 1) {
      return Image.network(
        widget.imageUrls[0],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 300,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "${_currentIndex + 1}/${widget.imageUrls.length}",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
