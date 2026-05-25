import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_header.dart';
import '../providers/diagnosis_history_provider.dart';
import 'diagnosis_history_detail_screen.dart';

class DiagnosisHistoryScreen extends ConsumerWidget {
  const DiagnosisHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(diagnosisHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomHeader(
        title: 'Lịch sử chuẩn đoán',
        showBackButton: true,
      ),
      body: historyAsync.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('Chưa có lịch sử chẩn đoán nào.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(diagnosisHistoryProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index] as Map<String, dynamic>;
                return _buildHistoryCard(context, item);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Đã có lỗi xảy ra: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(diagnosisHistoryProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> data) {
    final confidence = (data['confidenceScore'] ?? 0).toDouble();
    String severityLabel;
    Color badgeColor;
    Color badgeTextColor;

    if (confidence >= 80) {
      severityLabel = 'Nghiêm trọng';
      badgeColor = Colors.red.shade50;
      badgeTextColor = Colors.red.shade700;
    } else if (confidence >= 50) {
      severityLabel = 'Trung bình';
      badgeColor = Colors.orange.shade50;
      badgeTextColor = Colors.orange.shade800;
    } else {
      severityLabel = 'Nhẹ';
      badgeColor = Colors.green.shade50;
      badgeTextColor = Colors.green.shade700;
    }

    // Format date roughly (Backend returns e.g. "2026-05-05T10:24:45.112")
    String dateStr = data['createdAt'] ?? '';
    if (dateStr.length >= 10) {
      dateStr = '${dateStr.substring(8, 10)}/${dateStr.substring(5, 7)}/${dateStr.substring(0, 4)}';
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiagnosisHistoryDetailScreen(result: data),
          ),
        );
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anh benh
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                data['imageUrl'] ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Thong tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['plantName'] ?? 'Không xác định',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data['diseaseName'] ?? 'Không xác định',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge muc do
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          severityLabel,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Độ chính xác: ${confidence.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyGrey.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: AppTextStyles.bodyGrey.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
