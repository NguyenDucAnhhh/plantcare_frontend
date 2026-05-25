import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_form_bottom_sheet.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/custom_tab_switcher.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  int _selectedTabIndex = 0; // 0: Tất cả, 1: Đang theo dõi

  @override
  void initState() {
    super.initState();
    // Đợi widget dựng xong thì kiểm tra dữ liệu bài đăng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postsState = ref.read(postProvider);
      // Nếu danh sách đang trống, tự động load bài đăng của tài khoản hiện tại
      if (postsState.posts.isEmpty) {
        ref.read(postProvider.notifier).loadPosts();
      }
    });
  }

  void _showCreatePostForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PostFormBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHeader(
        title: 'Cộng đồng',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _showCreatePostForm,
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle Tabs (Tất cả / Đang theo dõi)
          CustomTabSwitcher(
            tabs: const ['Tất cả', 'Đang theo dõi'],
            selectedIndex: _selectedTabIndex,
            onTabChanged: (index) {
              setState(() => _selectedTabIndex = index);
              ref.read(postProvider.notifier).loadPosts(isFollowing: index == 1);
            },
          ),

          // Hiển thị danh sách bài đăng hoặc trạng thái Loading/Error
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(postProvider.notifier).loadPosts(
                isFollowing: _selectedTabIndex == 1,
              ),
              child: _buildMainContent(postsState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(PostState state) {
    // 1. Trường hợp đang tải dữ liệu và chưa có bài nào hiện có
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // 2. Trường hợp có lỗi và không có dữ liệu cũ
    if (state.error != null && state.posts.isEmpty) {
      return SingleChildScrollView( // Cho phép pull to refresh khi bị lỗi
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                state.error!.replaceAll('Exception: ', ''),
                style: AppTextStyles.body.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    // 3. Trường hợp dữ liệu trống
    if (state.posts.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Text('Chưa có bài đăng nào.', style: AppTextStyles.bodyGrey),
          ),
        ),
      );
    }

    // 4. Hiển thị danh sách bài đăng
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: state.posts[index]);
      },
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTabIndex != index) {
            setState(() => _selectedTabIndex = index);
            ref.read(postProvider.notifier).loadPosts(isFollowing: index == 1);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.textDark : AppColors.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}
