import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../post/models/post_model.dart';
import '../../../core/constants/app_text_styles.dart';

class ProfilePostsGrid extends StatelessWidget {
  final List<PostModel> posts;

  const ProfilePostsGrid({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.article_outlined, size: 48, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn chưa có bài đăng nào',
                style: AppTextStyles.bodyGrey.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(2),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = posts[index];
            final String? firstImage = post.imageUrls.isNotEmpty ? post.imageUrls.first : null;

            return GestureDetector(
              onTap: () => context.push('/post/${post.id}'),
              child: Container(
                color: Colors.grey.shade200,
                child: firstImage != null
                    ? Image.network(
                        firstImage,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: Text(
                          post.content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            );
          },
          childCount: posts.length,
        ),
      ),
    );
  }
}
