import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_header.dart';
import '../providers/care_tip_provider.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['Tất cả', 'Tưới nước', 'Bón phân', 'Phòng bệnh', 'Ánh sáng', 'Chung'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(careTipProvider.notifier).setSearchQuery(value);
  }

  void _onCategorySelected(String category) {
    ref.read(careTipProvider.notifier).setCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    final tipsState = ref.watch(careTipProvider);
    final selectedCategory = tipsState.selectedCategory ?? 'Tất cả';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeader(
        title: 'Mẹo chăm sóc cây',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm mẹo...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintStyle: AppTextStyles.bodyGrey,
                    ),
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = category == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _onCategorySelected(category),
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          labelStyle: AppTextStyles.body.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textGrey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // List of tips
          Expanded(
            child: tipsState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : tipsState.error != null
                    ? Center(child: Text('Lỗi: ${tipsState.error}', style: AppTextStyles.bodyGrey))
                    : tipsState.filteredTips.isEmpty
                        ? Center(child: Text('Không tìm thấy bài viết nào.', style: AppTextStyles.bodyGrey))
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () async {
                              await ref.read(careTipProvider.notifier).loadTips();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: tipsState.filteredTips.length,
                              itemBuilder: (context, index) {
                                final tip = tipsState.filteredTips[index];
                                
                                // Parse JSON to plain text for preview
                                String previewText = tip.content;
                                if (previewText.trim().startsWith('[')) {
                                  try {
                                    final List<dynamic> jsonList = jsonDecode(previewText);
                                    previewText = quill.Document.fromJson(jsonList).toPlainText();
                                  } catch (_) {}
                                }
                              return GestureDetector(
                                onTap: () {
                                  context.push('/tips/detail', extra: tip);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Cover Image
                                      if (tip.imageUrl != null && tip.imageUrl!.isNotEmpty)
                                        Hero(
                                          tag: 'tip_img_${tip.id}',
                                          child: Image.network(
                                            tip.imageUrl!,
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                                          ),
                                        )
                                      else
                                        _buildPlaceholderImage(),
                                      
                                      // Content
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.accentBlue.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    tip.category ?? 'Chung',
                                                    style: AppTextStyles.label.copyWith(color: AppColors.accentBlue, fontSize: 12),
                                                  ),
                                                ),
                                                const Spacer(),
                                                const Icon(Icons.access_time, size: 14, color: AppColors.textGrey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  tip.createdAt != null && tip.createdAt!.length >= 10 
                                                      ? tip.createdAt!.substring(0, 10) 
                                                      : '',
                                                  style: AppTextStyles.bodyGrey.copyWith(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              tip.title,
                                              style: AppTextStyles.heading3.copyWith(fontSize: 18),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              previewText,
                                              style: AppTextStyles.bodyGrey,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.eco_rounded, size: 48, color: Colors.grey),
      ),
    );
  }
}
