import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/error_mapper.dart';
import 'package:go_router/go_router.dart';
import '../models/admin_report_model.dart';
import '../providers/admin_reports_provider.dart';
import '../providers/admin_posts_provider.dart';
import '../widgets/admin_paginated_table.dart';
import '../widgets/admin_search_filter_bar.dart';

// State providers cho filters
final reportSearchQueryProvider = StateProvider<String>((ref) => '');
final reportFilterStatusProvider = StateProvider<String>((ref) => 'all'); // all, PENDING, KEPT, DELETED

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // Search and Filter Bar
        AdminSearchFilterBar(
          searchController: _searchController,
          searchHint: 'Tìm người tố cáo hoặc lý do...',
          onSearchChanged: (val) {
            ref.read(reportSearchQueryProvider.notifier).state = val;
          },
          filterValue: ref.watch(reportFilterStatusProvider),
          onFilterChanged: (val) {
            if (val != null) {
              ref.read(reportFilterStatusProvider.notifier).state = val;
            }
          },
          filterItems: const [
            DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: 'PENDING', child: Text('Chưa xử lý')),
            DropdownMenuItem(value: 'KEPT', child: Text('Đã bỏ qua')),
            DropdownMenuItem(value: 'DELETED', child: Text('Đã ẩn bài')),
          ],
        ),
        const SizedBox(height: 24),

        // Table
        Expanded(
          child: reportsAsync.when(
            data: (dataMap) {
              final reportsAsyncList = (dataMap['content'] as List<dynamic>?)?.cast<AdminReportModel>() ?? [];
              final totalElements = dataMap['totalElements'] as int? ?? reportsAsyncList.length;
              final currentPage = dataMap['number'] as int? ?? 0;

              final searchQuery = ref.watch(reportSearchQueryProvider).toLowerCase();
              final filterStatus = ref.watch(reportFilterStatusProvider);
              
              final reports = reportsAsyncList.where((r) {
                final matchesSearch = r.reporterName.toLowerCase().contains(searchQuery) || 
                                      r.reason.toLowerCase().contains(searchQuery);
                
                bool matchesStatus = true;
                if (filterStatus != 'all') {
                  matchesStatus = r.status == filterStatus;
                }
                
                return matchesSearch && matchesStatus;
              }).toList();

              return AdminPaginatedTable<AdminReportModel>(
                serverSideTotalElements: totalElements,
                serverSideCurrentPage: currentPage,
                onPageChanged: (page) {
                  ref.read(adminReportsProvider.notifier).fetchReports(page: page);
                },
                key: ValueKey('$searchQuery-$filterStatus'),
                columns: const [
                  DataColumn(label: SizedBox(width: 40, child: Text('ID'))),
                  DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Ngày tố cáo')))),
                  DataColumn(label: Text('Người tố cáo')),
                  DataColumn(label: Text('Lý do')),
                  DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Trạng thái')))),
                  DataColumn(label: SizedBox(width: 150, child: Center(child: Text('Thao tác')))),
                ],
                source: AdminDataSource<AdminReportModel>(
                  data: reports,
                  buildRow: (index, report) => _buildRow(context, ref, report),
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

  DataRow _buildRow(BuildContext context, WidgetRef ref, AdminReportModel report) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    
    Widget statusWidget;
    switch(report.status) {
      case 'KEPT':
        statusWidget = _buildStatusBadge('Đã bỏ qua', Colors.green);
        break;
      case 'DELETED':
        statusWidget = _buildStatusBadge('Đã ẩn', Colors.red);
        break;
      case 'PENDING':
      default:
        statusWidget = _buildStatusBadge('Chờ xử lý', Colors.orange);
        break;
    }

    return DataRow(
      cells: [
        DataCell(Text('${report.id}', style: AppTextStyles.body)),
        DataCell(SizedBox(width: 100, child: Center(child: Text(formatter.format(report.createdAt), style: AppTextStyles.body)))),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.reporterName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              if (report.reporterEmail != null) Text(report.reporterEmail!, style: AppTextStyles.body.copyWith(color: AppColors.textGrey, fontSize: 13)),
            ],
          )
        ),
        DataCell(Text(report.reason, style: AppTextStyles.body, maxLines: 2, overflow: TextOverflow.ellipsis)),
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
                    context.push('/post/${report.postId}');
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check_circle_outline, 
                    color: report.status == 'KEPT' ? Colors.grey : Colors.green,
                    size: 20,
                  ),
                  tooltip: 'Bỏ qua (Giữ bài)',
                  onPressed: () async {
                    try {
                      await ref.read(adminReportsProvider.notifier).resolveReport(report.id, 'KEEP_POST');
                      if (context.mounted) {
                        AppSnackbar.showSuccess(context, 'Đã giữ lại bài đăng!');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppSnackbar.showError(context, ErrorMapper.parseError(e));
                      }
                    }
                  },
                ),
                IconButton(
                  icon: Icon(report.postIsVisible ? Icons.visibility_off_outlined : Icons.restore, color: report.postIsVisible ? Colors.orange : Colors.green, size: 20),
                  tooltip: report.postIsVisible ? 'Ẩn bài đăng' : 'Hoàn tác ẩn',
                  onPressed: () async {
                    try {
                      await ref.read(adminPostsProvider.notifier).togglePostVisibility(report.postId);
                      if (context.mounted) {
                        AppSnackbar.showSuccess(context, report.postIsVisible ? 'Đã ẩn bài đăng!' : 'Đã hoàn tác ẩn bài đăng!');
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
          fontSize: 13,
        ),
      ),
    );
  }
}
