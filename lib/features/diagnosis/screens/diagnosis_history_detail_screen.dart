import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/widgets/custom_header.dart';
import '../providers/diagnosis_history_provider.dart';

class DiagnosisHistoryDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> result;

  const DiagnosisHistoryDetailScreen({super.key, required this.result});

  @override
  ConsumerState<DiagnosisHistoryDetailScreen> createState() => _DiagnosisHistoryDetailScreenState();
}

class _DiagnosisHistoryDetailScreenState extends ConsumerState<DiagnosisHistoryDetailScreen> {
  late int userFeedbackRating;

  @override
  void initState() {
    super.initState();
    userFeedbackRating = widget.result['userFeedbackRating'] ?? 0;
  }

  Future<void> _rate(int rating) async {
    final success = await ref.read(diagnosisHistoryProvider.notifier)
        .rateDiagnosis(widget.result['id'], rating);
    if (success && mounted) {
      setState(() {
        userFeedbackRating = rating;
      });
      AppSnackbar.showSuccess(context, 'Cảm ơn bạn đã đánh giá!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = (widget.result['confidenceScore'] ?? 0).toDouble();

    String dateStr = widget.result['createdAt'] ?? '';
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
                widget.result['imageUrl'] ?? '',
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
                    'Độ chính xác: $confidence% - $dateStr',
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
                                widget.result['plantName'] ?? 'Không xác định',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.result['diseaseName'] ?? 'Không xác định',
                                style: AppTextStyles.heading3.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Nguyen nhan
                    _buildInfoRow(Icons.info_outline, 'Nguyên nhân', widget.result['cause'] ?? 'Không xác định'),
                    const SizedBox(height: 16),

                    // Cach chua
                    _buildInfoRow(Icons.healing_outlined, 'Cách chữa', widget.result['treatment'] ?? 'Không xác định'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Rating Area
            Text(
              'Bạn thấy chẩn đoán này có chính xác không?',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRateBtn(Icons.thumb_up_alt_rounded, 'Chính xác', 1, AppColors.success),
                const SizedBox(width: 16),
                _buildRateBtn(Icons.thumb_down_alt_rounded, 'Không đúng', -1, Colors.red),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRateBtn(IconData icon, String label, int rateValue, Color color) {
    final isSelected = userFeedbackRating == rateValue;
    return InkWell(
      onTap: () => _rate(rateValue),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
