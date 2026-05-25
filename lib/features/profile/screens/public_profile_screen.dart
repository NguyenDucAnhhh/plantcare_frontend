import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
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
      body: CustomScrollView(
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
                          : const Center(child: Icon(Icons.image, color: Colors.grey)),
                    ),
                  );
                },
                childCount: posts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> profile, bool isFollowing) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nút quay lại
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  AppAvatar(
                    radius: 40,
                    imageUrl: profile['avatarUrl'],
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile['fullName'] ?? 'Người dùng',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profile['followersCount'] ?? 0}',
                                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                                ),
                                Text(
                                  'Người theo dõi',
                                  style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profile['followingCount'] ?? 0}',
                                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                                ),
                                Text(
                                  'Đang theo dõi',
                                  style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Bio
              if (profile['bio'] != null && profile['bio'].toString().isNotEmpty) ...[
                Text(
                  profile['bio'],
                  style: AppTextStyles.body.copyWith(color: Colors.white, height: 1.5),
                ),
                const SizedBox(height: 16),
              ],
              
              // Nút Theo dõi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(publicProfileProvider(widget.userId).notifier).toggleFollow();
                  },
                  icon: Icon(
                    isFollowing ? Icons.check : Icons.person_add_alt_1_outlined,
                    color: isFollowing ? Colors.white : AppColors.textDark,
                    size: 20,
                  ),
                  label: Text(
                    isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                    style: AppTextStyles.button.copyWith(
                      color: isFollowing ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.transparent : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isFollowing ? Colors.white : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
