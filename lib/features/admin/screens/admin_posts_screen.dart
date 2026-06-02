import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/error_mapper.dart';
import 'package:go_router/go_router.dart';
import '../models/admin_post_model.dart';
import '../providers/admin_posts_provider.dart';
import '../widgets/admin_paginated_table.dart';
import '../widgets/admin_search_filter_bar.dart';

final adminPostSearchProvider = StateProvider<String>((ref) => '');
final adminPostStatusFilterProvider = StateProvider<String>((ref) => 'all'); // all, visible, hidden

class AdminPostsScreen extends ConsumerStatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  ConsumerState<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends ConsumerState<AdminPostsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(adminPostsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // Search and Filter Bar
        AdminSearchFilterBar(
          searchController: _searchController,
          searchHint: 'Tìm người đăng hoặc nội dung...',
          onSearchChanged: (val) {
            ref.read(adminPostSearchProvider.notifier).state = val;
          },
          filterValue: ref.watch(adminPostStatusFilterProvider),
          onFilterChanged: (val) {
            if (val != null) {
              ref.read(adminPostStatusFilterProvider.notifier).state = val;
            }
          },
          filterItems: const [
            DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: 'visible', child: Text('Đang hiển thị')),
            DropdownMenuItem(value: 'hidden', child: Text('Đã ẩn')),
          ],
        ),
        const SizedBox(height: 24),

        // Table
        Expanded(
          child: postsAsync.when(
            data: (dataMap) {
              final postsList = (dataMap['content'] as List<dynamic>?)?.cast<AdminPostModel>() ?? [];
              final totalElements = dataMap['totalElements'] as int? ?? postsList.length;
              final currentPage = dataMap['number'] as int? ?? 0;
              
              final searchQuery = ref.watch(adminPostSearchProvider).toLowerCase();
              final filterStatus = ref.watch(adminPostStatusFilterProvider);
              
              final posts = postsList.where((p) {
                final matchesSearch = p.authorName.toLowerCase().contains(searchQuery) || 
                                      p.content.toLowerCase().contains(searchQuery);
                
                bool matchesStatus = true;
                if (filterStatus == 'visible') {
                  matchesStatus = p.isVisible == true;
                } else if (filterStatus == 'hidden') {
                  matchesStatus = p.isVisible == false;
                }
                
                return matchesSearch && matchesStatus;
              }).toList();

              return AdminPaginatedTable<AdminPostModel>(
                serverSideTotalElements: totalElements,
                serverSideCurrentPage: currentPage,
                onPageChanged: (page) {
                  ref.read(adminPostsProvider.notifier).loadPosts(page: page);
                },
                key: ValueKey('$searchQuery-$filterStatus'),
                columns: const [
                  DataColumn(label: SizedBox(width: 60, child: Text('ID'))),
                  DataColumn(label: Text('Người đăng')),
                  DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Ngày đăng')))),
                  DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Trạng thái')))),
                  DataColumn(label: SizedBox(width: 150, child: Center(child: Text('Thao tác')))),
                ],
                source: AdminDataSource<AdminPostModel>(
                  data: posts,
                  buildRow: (index, post) => _buildRow(context, ref, post),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Lỗi: $e')),
          ),
        ),
      ],
    );
  }

  DataRow _buildRow(BuildContext context, WidgetRef ref, AdminPostModel post) {
    String dateStr = post.createdAt;
    if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);
    
    Widget statusWidget = post.isVisible
        ? _buildStatusBadge('Đang hiển thị', Colors.green)
        : _buildStatusBadge('Đã ẩn', Colors.red);

    return DataRow(
      cells: [
        DataCell( Text('${post.id}', style: AppTextStyles.body)),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.authorName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              if (post.authorEmail.isNotEmpty) Text(post.authorEmail, style: AppTextStyles.body.copyWith(color: AppColors.textGrey, fontSize: 13)),
            ],
          )
        ),
        DataCell(SizedBox(width: 100, child: Center(child: Text(dateStr, style: AppTextStyles.bodyGrey)))),
        DataCell(SizedBox(width: 100, child: Center(child: statusWidget))),
        DataCell(
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20),
                  tooltip: 'Xem bài đăng',
                  onPressed: () {
                    context.push('/post/${post.id}');
                  },
                ),
                IconButton(
                  icon: Icon(post.isVisible ? Icons.visibility_off_outlined : Icons.restore, color: post.isVisible ? Colors.orange : Colors.green, size: 20),
                  tooltip: post.isVisible ? 'Ẩn bài đăng' : 'Hoàn tác ẩn',
                  onPressed: () async {
                    try {
                      await ref.read(adminPostsProvider.notifier).togglePostVisibility(post.id);
                      if (context.mounted) {
                        AppSnackbar.showSuccess(context, post.isVisible ? 'Đã ẩn bài đăng!' : 'Đã hoàn tác ẩn bài đăng!');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppSnackbar.showError(context, ErrorMapper.parseError(e));
                      }
                    }
                  },
                ),
              ],
            ),
          )
        ),
      ],
    );
  }



  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
