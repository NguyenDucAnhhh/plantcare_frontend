import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/care_tip_model.dart';

class TipDetailScreen extends StatelessWidget {
  final CareTipModel tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    String dateStr = tip.createdAt ?? '';
    if (dateStr.length >= 10) {
      dateStr = '${dateStr.substring(8, 10)}/${dateStr.substring(5, 7)}/${dateStr.substring(0, 4)}';
    }

    QuillController? quillController;
    if (tip.content.isNotEmpty) {
      try {
        final jsonDelta = jsonDecode(tip.content);
        quillController = QuillController(
          document: Document.fromJson(jsonDelta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        quillController = QuillController(
          document: Document()..insert(0, tip.content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
      quillController.readOnly = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar voi hinh anh
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'tip_img_${tip.id}',
                child: tip.imageUrl != null && tip.imageUrl!.isNotEmpty
                    ? Image.network(
                        tip.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),

          // Noi dung bai viet
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge category & date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tip.category ?? 'Chung',
                            style: AppTextStyles.label.copyWith(color: AppColors.accentBlue),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textGrey),
                        const SizedBox(width: 6),
                        Text(dateStr, style: AppTextStyles.bodyGrey),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tieu de
                    Text(
                      tip.title,
                      style: AppTextStyles.heading1.copyWith(fontSize: 24, height: 1.3),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 24),

                    // Noi dung
                    if (quillController != null)
                      QuillEditor.basic(
                        controller: quillController,
                      )
                    else
                      Text(
                        tip.content,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.eco_rounded, size: 64, color: Colors.grey),
      ),
    );
  }
}
