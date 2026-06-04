import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_form_bottom_sheet.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/custom_tab_switcher.dart';

import 'package:go_router/go_router.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  int _selectedTabIndex = 0; // 0: Tất cả, 1: Đang theo dõi
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Đợi widget dựng xong thì kiểm tra dữ liệu bài đăng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postsState = ref.read(postProvider);
      // Nếu danh sách đang trống, tự động load bài đăng của tài khoản hiện tại
      if (postsState.posts.isEmpty) {
        ref.read(postProvider.notifier).loadPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(postProvider.notifier).loadMorePosts(isFollowing: _selectedTabIndex == 1);
    }
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
            icon: const Icon(Icons.search, color: Colors.white, size: 26),
            onPressed: () {
              context.push('/community-search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 26),
            onPressed: () {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(0.0);
              }
              _refreshIndicatorKey.currentState?.show();
            },
          ),
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
              key: _refreshIndicatorKey,
              onRefresh: () => ref.read(postProvider.notifier).refreshPosts(
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
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        return PostCard(post: state.posts[index]);
      },
    );
  }

}
