import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_header.dart';

class DiagnosisHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const DiagnosisHistoryDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final confidence = (result['confidenceScore'] ?? 0).toDouble();
    final Color severityColor = confidence >= 80
        ? Colors.red.shade600
        : confidence >= 50
            ? Colors.orange.shade700
            : Colors.green.shade600;
    final String severityLabel = confidence >= 80
        ? 'Nghiêm trọng'
        : confidence >= 50
            ? 'Trung bình'
            : 'Nhẹ';

    String dateStr = result['createdAt'] ?? '';
    if (dateStr.length >= 10) {
      dateStr = '${dateStr.substring(8, 10)}/${dateStr.substring(5, 7)}/${dateStr.substring(0, 4)}';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeader(
        title: 'Chi tiết kết quả AI',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Anh benh
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                result['imageUrl'] ?? '',
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
                    'Độ chính xác: ${confidence.toStringAsFixed(0)}% • $dateStr',
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
                    // Ten cay + Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result['plantName'] ?? 'Không xác định',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result['diseaseName'] ?? 'Không xác định',
                                style: AppTextStyles.heading3.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            severityLabel,
                            style: TextStyle(color: severityColor, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Nguyen nhan
                    _buildInfoRow(Icons.info_outline, 'Nguyên nhân', result['cause'] ?? 'Không xác định'),
                    const SizedBox(height: 16),

                    // Cach chua
                    _buildInfoRow(Icons.healing_outlined, 'Cách chữa', result['treatment'] ?? 'Không xác định'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
}
