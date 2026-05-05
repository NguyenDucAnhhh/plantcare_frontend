import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Bien cuc bo de thay doi avatar truoc khi luu len server
  String? localAvatarPath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Tự động tải lại dữ liệu mỗi khi vào màn hình Profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(profileProvider);
      // Chỉ gọi API nếu dữ liệu đang trống
      if (profileState.profile == null) {
        ref.read(profileProvider.notifier).loadProfileData();
      }
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showQrDialog(Map<String, dynamic> profile) {
    final userId = profile['id'] ?? 0;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // can bang de center tieu de
                    Text(
                      'Mã QR hồ sơ của bạn',
                      style: AppTextStyles.heading3,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: AppColors.textGrey, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                QrImageView(
                  data: "https://plantcare.app/user/$userId",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 32),
                Text(
                  'Quét mã này để xem hồ sơ của bạn',
                  style: AppTextStyles.bodyGrey.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(Map<String, dynamic> profile) {
    final nameCtrl = TextEditingController(text: profile['fullName'] ?? '');
    final bioCtrl = TextEditingController(text: profile['bio'] ?? 'Chưa có thông tin giới thiệu.');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 24),
                          Text(
                            'Chỉnh sửa hồ sơ',
                            style: AppTextStyles.heading3,
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: AppColors.textGrey, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Avatar
                      Text('Ảnh đại diện', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Builder(
                              builder: (context) {
                                final ImageProvider? dialogImageProvider = localAvatarPath != null
                                    ? (kIsWeb ? NetworkImage(localAvatarPath!) as ImageProvider : FileImage(File(localAvatarPath!)))
                                    : (profile['avatarUrl'] != null ? NetworkImage(profile['avatarUrl']) as ImageProvider : null);

                                return CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: dialogImageProvider,
                                  child: dialogImageProvider == null
                                      ? Icon(Icons.person, size: 40, color: Colors.grey.shade400)
                                      : null,
                                );
                              }
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    setStateDialog(() {
                                      localAvatarPath = image.path;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.textDark),
                                label: const Text('Chọn ảnh', style: TextStyle(color: AppColors.textDark)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Tối đa 5MB', style: AppTextStyles.bodyGrey.copyWith(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Ten hien thi
                      Text('Tên hiển thị', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Gioi thieu
                      Text('Giới thiệu', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: bioCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Viết vài dòng về bạn...',
                          filled: true,
                          fillColor: AppColors.inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nut luu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final repo = ref.read(profileRepositoryProvider);
                              
                              // Upload anh truoc neu co thay doi
                              if (localAvatarPath != null && !kIsWeb) {
                                await repo.uploadAvatar(localAvatarPath!);
                              }
                              
                              // Sau do cap nhat thong tin khac
                              await repo.updateProfile({
                                'fullName': nameCtrl.text,
                                'bio': bioCtrl.text,
                              });
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                ref.read(profileProvider.notifier).loadProfileData(); // Reload
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi cập nhật: $e')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading && profileState.profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final profile = profileState.profile ?? {};

    final fullName = profile['fullName'];
    final bio = profile['bio'] ?? 'Chưa có thông tin giới thiệu';
    final followers = profile['followersCount'] ?? 0;
    final following = profile['followingCount'] ?? 0;
    final avatarUrl = profile['avatarUrl'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // === HEADER XANH LA ===
          Container(
            color: const Color(0xFF00C853), // Mau xanh la nhat theo Figma
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    // Top Bar (Icons)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () {},
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),

                    // Avatar + Info
                    Row(
                      children: [
                        // Avatar
                        Builder(
                            builder: (context) {
                              final ImageProvider? headerImageProvider = localAvatarPath != null
                                  ? (kIsWeb ? NetworkImage(localAvatarPath!) as ImageProvider : FileImage(File(localAvatarPath!)))
                                  : (avatarUrl != null ? NetworkImage(avatarUrl) as ImageProvider : null);

                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200, // Đổ nền xám cho icon
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  image: headerImageProvider != null
                                      ? DecorationImage(
                                    image: headerImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: headerImageProvider == null
                                    ? Icon(Icons.person, size: 40, color: Colors.grey.shade400)
                                    : null,
                              );
                            }
                        ),
                        const SizedBox(width: 16),
                        // Name & Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: AppTextStyles.heading2.copyWith(color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$followers', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                                      Text('Người theo dõi', style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$following', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                                      Text('Đang theo dõi', style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12)),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        bio,
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showEditProfileDialog(profile),
                            icon: const Icon(Icons.edit_outlined, color: AppColors.textDark, size: 18),
                            label: const Text('Chỉnh sửa', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showQrDialog(profile),
                            icon: const Icon(Icons.qr_code, color: AppColors.textDark, size: 18),
                            label: const Text('Mã QR', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // === TAB BAR ===
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.textDark,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor: AppColors.textDark,
              labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Bài đăng'),
                Tab(text: 'Vườn cây'),
              ],
            ),
          ),

          // === TAB CONTENT ===
          Expanded(
            child: profileState.isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab Bai dang
                    profileState.posts.isEmpty 
                      ? _buildEmptyState('Bạn chưa có bài đăng nào', Icons.article_outlined) 
                      : _buildPostsGrid(profileState.posts),
                    // Tab Vuon cay
                    profileState.gardens.isEmpty 
                      ? _buildEmptyState('Bạn chưa có vườn cây nào', Icons.local_florist_outlined) 
                      : _buildGardensList(profileState.gardens),
                  ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyGrey.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(List<dynamic> posts) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Container(
          color: Colors.grey.shade200,
          child: post['imageUrl'] != null 
            ? Image.network(post['imageUrl'], fit: BoxFit.cover)
            : const Center(child: Icon(Icons.image, color: Colors.grey)),
        );
      },
    );
  }

  Widget _buildGardensList(List<dynamic> gardens) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: gardens.length,
      itemBuilder: (context, index) {
        final garden = gardens[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Colors.grey),
            ),
            title: Text(garden['name'] ?? 'Vườn cây'),
            subtitle: Text('${garden['plants']?.length ?? 0} cây trồng'),
          ),
        );
      },
    );
  }
}
