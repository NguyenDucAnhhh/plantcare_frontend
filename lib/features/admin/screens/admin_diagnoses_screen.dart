import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/error_mapper.dart';
import '../providers/admin_diagnoses_provider.dart';
import '../widgets/admin_paginated_table.dart';
import '../widgets/admin_search_filter_bar.dart';

// State providers cho filters
final diagSearchQueryProvider = StateProvider<String>((ref) => '');
final diagFilterStatusProvider = StateProvider<String>((ref) => 'all'); // all, verified, unverified
final diagFilterRatingProvider = StateProvider<int?>((ref) => null); // null=all, 1, -1
final diagFilterConfidenceProvider = StateProvider<String>((ref) => 'all'); // all, low, medium, high

class AdminDiagnosesScreen extends ConsumerStatefulWidget {
  const AdminDiagnosesScreen({super.key});

  @override
  ConsumerState<AdminDiagnosesScreen> createState() => _AdminDiagnosesScreenState();
}

class _AdminDiagnosesScreenState extends ConsumerState<AdminDiagnosesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(diagSearchQueryProvider.notifier).state = value;
    ref.read(adminDiagnosesProvider.notifier).setFilters(search: value);
  }

  @override
  Widget build(BuildContext context) {
    final diagnosesAsync = ref.watch(adminDiagnosesProvider);
    final filterStatus = ref.watch(diagFilterStatusProvider);
    final filterRating = ref.watch(diagFilterRatingProvider);
    final filterConfidence = ref.watch(diagFilterConfidenceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // Search and Filter Bar
        AdminSearchFilterBar(
          searchController: _searchController,
          searchHint: 'Tìm theo bệnh, cây, email...',
          onSearchChanged: _onSearchChanged,
          filterValue: filterStatus,
          onFilterChanged: (val) {
            if (val != null) {
              ref.read(diagFilterStatusProvider.notifier).state = val;
              ref.read(adminDiagnosesProvider.notifier).setFilters(status: val);
            }
          },
          filterItems: const [
            DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: 'verified', child: Text('Đã duyệt')),
            DropdownMenuItem(value: 'unverified', child: Text('Chưa duyệt')),
          ],
          extraFilters: [
            AdminFilterDropdown<int>(
              value: filterRating ?? -99,
              onChanged: (val) {
                if (val != null) {
                  ref.read(diagFilterRatingProvider.notifier).state = val == -99 ? null : val;
                  ref.read(adminDiagnosesProvider.notifier).setFilters(rating: val);
                }
              },
              items: const [
                DropdownMenuItem(value: -99, child: Text('Đánh giá')),
                DropdownMenuItem(value: 1, child: Text('Hữu ích')),
                DropdownMenuItem(value: -1, child: Text('Chưa tốt')),
              ],
            ),
            AdminFilterDropdown<String>(
              value: filterConfidence,
              onChanged: (val) {
                if (val != null) {
                  ref.read(diagFilterConfidenceProvider.notifier).state = val;
                  ref.read(adminDiagnosesProvider.notifier).setFilters(confidence: val);
                }
              },
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Độ tự tin')),
                DropdownMenuItem(value: 'high', child: Text('Cao')),
                DropdownMenuItem(value: 'medium', child: Text('Trung Bình')),
                DropdownMenuItem(value: 'low', child: Text('Thấp')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Table
        Expanded(
          child: diagnosesAsync.when(
            data: (data) {
              final contentList = (data['content'] as List?) ?? [];
              final totalElements = data['totalElements'] as int? ?? contentList.length;
              final currentPage = data['number'] as int? ?? 0;
              
              return AdminPaginatedTable<Map<String, dynamic>>(
                serverSideTotalElements: totalElements,
                serverSideCurrentPage: currentPage,
                onPageChanged: (page) {
                  ref.read(adminDiagnosesProvider.notifier).fetchDiagnoses(page: page);
                },
                columns: const [
                  DataColumn(label: SizedBox(width: 40, child: Text('ID'))),
                  DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Ngày')))),
                  DataColumn(label: Text('Người dùng')),
                  DataColumn(label: Text('Tên cây')),
                  DataColumn(label: SizedBox(width: 80, child: Center(child: Text('Độ tự tin')))),
                  DataColumn(label: SizedBox(width: 100, child: Center(child: Text('User Vote')))),
                  DataColumn(label: SizedBox(width: 120, child: Center(child: Text('Trạng thái')))),
                  DataColumn(label: SizedBox(width: 120, child: Center(child: Text('Thao tác')))),
                ],
                source: AdminDataSource<Map<String, dynamic>>(
                  data: contentList.cast<Map<String, dynamic>>(),
                  buildRow: (index, item) => _buildRow(context, ref, item),
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

  DataRow _buildRow(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    final dateStr = item['createdAt'] ?? '';
    String formattedDate = '';
    if (dateStr.length >= 10) {
      formattedDate = '${dateStr.substring(8, 10)}/${dateStr.substring(5, 7)}/${dateStr.substring(0, 4)}';
    }
    
    final int rating = item['userFeedbackRating'] ?? 0;
    Widget ratingWidget = const Text('-');
    if (rating == 1) ratingWidget = const Icon(Icons.thumb_up, color: Colors.green, size: 20);
    if (rating == -1) ratingWidget = const Icon(Icons.thumb_down, color: Colors.red, size: 20);

    final bool? isCorrect = item['adminIsCorrect'];
    Widget statusWidget;
    if (isCorrect == null) {
      statusWidget = _buildStatusBadge('Chưa duyệt', Colors.orange);
    } else if (isCorrect) {
      statusWidget = _buildStatusBadge('Chính xác', Colors.green);
    } else {
      statusWidget = _buildStatusBadge('Sai bệnh', Colors.red);
    }

    return DataRow(
      cells: [
        DataCell(Text('${item['id'] ?? ''}', style: AppTextStyles.body)),
        DataCell(SizedBox(width: 100, child: Center(child: Text(formattedDate, style: AppTextStyles.body)))),
        DataCell(Text(item['userEmail'] ?? 'Unknown', style: AppTextStyles.body, maxLines: 1, overflow: TextOverflow.ellipsis)),
        DataCell(Text(item['plantName'] ?? 'Unknown', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold))),
        DataCell(SizedBox(width: 80, child: Center(child: Text('${item['confidenceScore'] ?? 0}%')))),
        DataCell(SizedBox(width: 100, child: Center(child: ratingWidget))),
        DataCell(SizedBox(width: 120, child: Center(child: statusWidget))),
        DataCell(
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20),
                  tooltip: 'Xem chi tiết',
                  onPressed: () {
                    _showDetailAndEvaluateDialog(context, ref, item);
                  },
                ),
              ],
            ),
          )
        ),
      ],
    );
  }

  void _showDetailAndEvaluateDialog(BuildContext outerContext, WidgetRef ref, Map<String, dynamic> item) {
    final noteController = TextEditingController(text: item['adminNote'] ?? '');
    bool isCorrect = item['adminIsCorrect'] ?? true;
    final id = item['id'] as int;

    final confidence = (item['confidenceScore'] ?? 0).toDouble();

    String dateStr = item['createdAt'] ?? '';
    if (dateStr.length >= 10) {
      dateStr = '${dateStr.substring(8, 10)}/${dateStr.substring(5, 7)}/${dateStr.substring(0, 4)}';
    }

    showDialog(
      context: outerContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 600,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chi tiết kết quả & Đánh giá', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Anh benh (Neu co URL tu item, con khong dung icon default)
                      if (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            item['imageUrl'],
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, color: Colors.grey, size: 50),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 50)),
                        ),
                      const SizedBox(height: 16),

                      // Badge ket qua
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.8), const Color(0xFF43A047)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Kết quả chẩn đoán',
                              style: AppTextStyles.heading3.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Độ chính xác: ${confidence.toInt()}% - $dateStr',
                              style: AppTextStyles.body.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chi tiet ket qua
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['plantName'] ?? 'Không xác định',
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['diseaseName'] ?? 'Không xác định',
                                          style: AppTextStyles.heading3.copyWith(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(Icons.info_outline, 'Nguyên nhân', item['cause'] ?? 'Không xác định'),
                              const SizedBox(height: 16),
                              _buildInfoRow(Icons.healing_outlined, 'Cách chữa', item['treatment'] ?? 'Không xác định'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Phan danh gia chuyen gia
                      Text('Đánh giá của chuyên gia', style: AppTextStyles.heading3),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('AI chẩn đoán đúng', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              value: true,
                              groupValue: isCorrect,
                              activeColor: Colors.green,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) {
                                if (val != null) setState(() => isCorrect = val);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('AI chẩn đoán sai', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              value: false,
                              groupValue: isCorrect,
                              activeColor: Colors.red,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) {
                                if (val != null) setState(() => isCorrect = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: noteController,
                          decoration: const InputDecoration(
                            labelText: 'Bệnh thực sự là gì? (Ghi chú)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        )
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(builderContext).pop(),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 16),
                          FilledButton(
                              onPressed: () async {
                                Navigator.pop(builderContext);
                                try {
                                  await ref.read(adminDiagnosesProvider.notifier)
                                      .evaluateDiagnosis(id, isCorrect, isCorrect ? '' : noteController.text.trim());
                                  if (mounted) {
                                    AppSnackbar.showSuccess(outerContext, 'Lưu đánh giá thành công!');
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    AppSnackbar.showError(outerContext, ErrorMapper.parseError(e));
                                  }
                                }
                              },
                            child: const Text('Lưu đánh giá'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.bodyGrey.copyWith(fontSize: 14)),
            ],
          ),
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
