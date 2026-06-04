import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/public_profile_provider.dart';
import '../widgets/profile_header.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicProfileProvider(widget.userId));

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Lỗi: ${state.error}', style: AppTextStyles.body)),
      );
    }

    final profile = state.profile;
    final posts = state.posts;

    if (profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Không tìm thấy thông tin người dùng')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(publicProfileProvider(widget.userId).notifier).loadProfile(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child:
              ProfileHeader(
                onBack: () => context.pop(),
                avatarUrl: profile['avatarUrl'],
                fullName: profile['fullName'] ?? 'Người dùng',
                followersCount: profile['followersCount'] ?? 0,
                followingCount: profile['followingCount'] ?? 0,
                bio: profile['bio'],
                actionRow: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(publicProfileProvider(widget.userId).notifier).toggleFollow(),
                    icon: Icon(state.isFollowing ? Icons.check : Icons.person_add),
                    label: Text(state.isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isFollowing ? Colors.white : Colors.white,
                      side: BorderSide(
                        color: state.isFollowing ? Colors.transparent : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

            ),

            // Lưới ảnh (Grid)
            SliverPadding(
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
            ),
          ],
        ),
      ),
    );
  }

}
