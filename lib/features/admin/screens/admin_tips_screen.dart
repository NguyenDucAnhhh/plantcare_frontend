import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../tips/data/care_tip_model.dart';
import '../providers/admin_tips_provider.dart';
import '../widgets/admin_paginated_table.dart';
import '../widgets/admin_search_filter_bar.dart';

// Providers cho filters
final tipSearchQueryProvider = StateProvider<String>((ref) => '');
final tipFilterCategoryProvider = StateProvider<String>((ref) => 'Tất cả');

class AdminTipsScreen extends ConsumerStatefulWidget {
  const AdminTipsScreen({super.key});

  @override
  ConsumerState<AdminTipsScreen> createState() => _AdminTipsScreenState();
}

class _AdminTipsScreenState extends ConsumerState<AdminTipsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['Tất cả', 'Tưới nước', 'Bón phân', 'Phòng bệnh', 'Ánh sáng', 'Chung'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(tipSearchQueryProvider.notifier).state = value;
    // Client-side filtering only applies to current page now
  }

  void _onCategoryChanged(String? val) {
    if (val != null) {
      ref.read(tipFilterCategoryProvider.notifier).state = val;
      // Client-side filtering only applies to current page now
    }
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài đăng này không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
                final success = await ref.read(adminTipsProvider.notifier).deleteTip(id);
                if (mounted) {
                  if (success) {
                    AppSnackbar.showSuccess(context, 'Đã xóa mẹo chăm sóc');
                  } else {
                    AppSnackbar.showError(context, 'Lỗi: Không thể xóa mẹo chăm sóc');
                  }
                }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipsAsync = ref.watch(adminTipsProvider);
    final filterCategory = ref.watch(tipFilterCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/tips/edit'),
              icon: const Icon(Icons.add),
              label: const Text('Thêm mẹo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Search and Filter Bar
        AdminSearchFilterBar(
          searchController: _searchController,
          searchHint: 'Tìm theo tiêu đề...',
          onSearchChanged: _onSearchChanged,
          filterValue: filterCategory,
          onFilterChanged: _onCategoryChanged,
          filterItems: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        ),
        const SizedBox(height: 16),

        // Table
        Expanded(
          child: tipsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi: $err')),
            data: (dataMap) {
              final tipsList = (dataMap['content'] as List<dynamic>?)?.cast<CareTipModel>() ?? [];
              final totalElements = dataMap['totalElements'] as int? ?? tipsList.length;
              final currentPage = dataMap['number'] as int? ?? 0;

              final searchQuery = ref.watch(tipSearchQueryProvider).toLowerCase();
              
              final filteredTips = tipsList.where((tip) {
                final matchSearch = searchQuery.isEmpty || 
                    tip.title.toLowerCase().contains(searchQuery);
                final matchCategory = filterCategory == 'Tất cả' ||
                    tip.category == filterCategory;
                return matchSearch && matchCategory;
              }).toList();

              return AdminPaginatedTable<CareTipModel>(
                serverSideTotalElements: totalElements,
                serverSideCurrentPage: currentPage,
                onPageChanged: (page) {
                  ref.read(adminTipsProvider.notifier).loadTips(page: page);
                },
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Hình ảnh')),
                  DataColumn(label: Text('Tiêu đề')),
                  DataColumn(label: Text('Danh mục')),
                  DataColumn(label: Text('Ngày tạo')),
                  DataColumn(label: Text('Thao tác')),
                ],
                source: AdminDataSource<CareTipModel>(
                  data: filteredTips,
                  buildRow: (index, tip) {
                    String dateStr = tip.createdAt ?? '';
                    if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);
                    return DataRow(
                      cells: [
                        DataCell(Text('${tip.id}', style: AppTextStyles.body)),
                        DataCell(
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: tip.imageUrl != null && tip.imageUrl!.isNotEmpty
                                ? Image.network(tip.imageUrl!, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image, color: Colors.grey))
                                : Container(width: 40, height: 40, color: Colors.grey.shade200, child: const Icon(Icons.article, color: Colors.grey)),
                          ),
                        ),
                        DataCell(Text(tip.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(tip.category ?? 'Chung', style: const TextStyle(color: AppColors.accentBlue, fontSize: 12)),
                          ),
                        ),
                        DataCell(Text(dateStr, style: AppTextStyles.bodyGrey)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: 'Cập nhật',
                                child: IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                  onPressed: () => context.push('/admin/tips/edit', extra: tip),
                                ),
                              ),
                              Tooltip(
                                message: 'Xoá',
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () => _showDeleteConfirm(context, ref, tip.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
