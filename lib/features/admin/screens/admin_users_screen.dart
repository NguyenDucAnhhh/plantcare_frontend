import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/admin_user_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_paginated_table.dart';
import '../widgets/admin_search_filter_bar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/error_mapper.dart';

final userSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final userFilterStatusProvider = StateProvider.autoDispose<String>((ref) => 'all');

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // Search and Filter Bar
        AdminSearchFilterBar(
          searchHint: 'Tìm kiếm người dùng...',
          onSearchChanged: (value) => ref.read(userSearchQueryProvider.notifier).state = value,
          filterValue: ref.watch(userFilterStatusProvider),
          onFilterChanged: (String? newValue) {
            if (newValue != null) {
              ref.read(userFilterStatusProvider.notifier).state = newValue;
            }
          },
          filterItems: const [
            DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: 'active', child: Text('Hoạt động')),
            DropdownMenuItem(value: 'locked', child: Text('Đã khóa')),
          ],
        ),
        const SizedBox(height: 24),

        // Table
        Expanded(
          child: usersAsync.when(
      data: (dataMap) {
          final usersAsyncList = (dataMap['content'] as List<dynamic>?)?.cast<AdminUserModel>() ?? [];
          final totalElements = dataMap['totalElements'] as int? ?? usersAsyncList.length;
          final currentPage = dataMap['number'] as int? ?? 0;

          final searchQuery = ref.watch(userSearchQueryProvider).toLowerCase();
          final filterStatus = ref.watch(userFilterStatusProvider);
          
          // Client-side filtering is now applied ONLY to the current page.
          // True server-side filtering requires backend endpoint updates.
          final users = usersAsyncList.where((user) {
            bool matchesSearch = user.fullName.toLowerCase().contains(searchQuery) ||
                                 user.email.toLowerCase().contains(searchQuery);
            bool matchesStatus = filterStatus == 'all' || 
                                 (filterStatus == 'active' ? user.isActive : !user.isActive);
            return matchesSearch && matchesStatus;
          }).toList();

          return AdminPaginatedTable<AdminUserModel>(
            serverSideTotalElements: totalElements,
            serverSideCurrentPage: currentPage,
            onPageChanged: (page) {
              ref.read(adminUsersProvider.notifier).fetchUsers(page: page);
            },
            key: ValueKey('$searchQuery-$filterStatus'),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Người dùng')),
            DataColumn(label: Text('Email')),
            DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Vai trò')))),
            DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Trạng thái')))),
            DataColumn(label: SizedBox(width: 120, child: Center(child: Text('Ngày tham gia')))),
            DataColumn(label: SizedBox(width: 80, child: Center(child: Text('Bài đăng')))),
            DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Thao tác')))),
          ],
          source: AdminDataSource<AdminUserModel>(
            data: users,
            buildRow: (index, user) => _buildRow(context, ref, user),
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

  DataRow _buildRow(BuildContext context, WidgetRef ref, AdminUserModel user) {
    final bool isLocked = !user.isActive;

    final bool isAdmin = user.role == 'ADMIN';
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    String formattedDate = '';
    try {
      if (user.createdAt.isNotEmpty) {
        formattedDate = formatter.format(DateTime.parse(user.createdAt));
      }
    } catch (e) {
      formattedDate = user.createdAt;
    }

    return DataRow(
      cells: [
        DataCell(Text('${user.id}', style: AppTextStyles.body)),
        DataCell(Text(user.fullName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold))),
        DataCell(Text(user.email)),
        DataCell(
          SizedBox(
            width: 100,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin ? AppColors.textDark : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isAdmin ? 'Quản trị' : 'Người dùng',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: isAdmin ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isLocked ? 'Đã khóa' : 'Hoạt động',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: isLocked ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        DataCell(SizedBox(width: 120, child: Center(child: Text(formattedDate)))),
        DataCell(SizedBox(width: 80, child: Center(child: Text('${user.postCount}')))),
        DataCell(
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isAdmin ? Icons.person_outline : Icons.admin_panel_settings_outlined, 
                    color: isAdmin ? Colors.blue : Colors.orange, 
                    size: 20
                  ),
                  tooltip: isAdmin ? 'Hạ quyền xuống User' : 'Nâng cấp lên Admin',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () async {
                      try {
                        await ref.read(adminUsersProvider.notifier).changeUserRole(user.id, isAdmin ? 'USER' : 'ADMIN');
                        if (context.mounted) {
                          AppSnackbar.showSuccess(context, 'Cập nhật quyền thành công!');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppSnackbar.showError(context, ErrorMapper.parseError(e));
                        }
                      }
                    },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isLocked ? Icons.lock_open : Icons.lock_outline, 
                    color: isLocked ? Colors.green : Colors.red, 
                    size: 20
                  ),
                  tooltip: isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () async {
                      try {
                        await ref.read(adminUsersProvider.notifier).toggleUserStatus(user.id);
                        if (context.mounted) {
                          AppSnackbar.showSuccess(context, isLocked ? 'Mở khóa thành công!' : 'Khóa thành công!');
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
          ),
        ),
      ],
    );
  }
}
