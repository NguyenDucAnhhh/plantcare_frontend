import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/post_provider.dart';

class ReportPostDialog extends ConsumerStatefulWidget {
  final String postId;
  
  const ReportPostDialog({super.key, required this.postId});

  @override
  ConsumerState<ReportPostDialog> createState() => _ReportPostDialogState();
}

class _ReportPostDialogState extends ConsumerState<ReportPostDialog> {
  final TextEditingController _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Báo cáo bài đăng',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn có chắc chắn muốn báo cáo bài đăng này? Chúng tôi sẽ xem xét và xử lý phù hợp.',
              style: AppTextStyles.bodyGrey.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _reasonCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nội dung báo cáo',
                  hintStyle: AppTextStyles.bodyGrey,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.textLight),
                    ),
                    child: Text('Hủy', style: AppTextStyles.button.copyWith(color: AppColors.textDark)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_reasonCtrl.text.trim().isEmpty) return;
                      try {
                        await ref.read(postProvider.notifier).reportPost(widget.postId, _reasonCtrl.text);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã gửi báo cáo thành công')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Báo cáo', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
