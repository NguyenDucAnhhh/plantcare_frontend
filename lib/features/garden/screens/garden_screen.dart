import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/garden_provider.dart';
import '../models/garden_model.dart';
import '../widgets/garden_form_bottom_sheet.dart';
import '../widgets/confirm_delete_dialog.dart';
import 'garden_detail_screen.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/app_popup_menu.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> {
  @override
  void initState() {
    super.initState();
    // Đợi widget dựng xong thì kiểm tra dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gardenState = ref.read(gardenProvider);
      // Nếu danh sách vườn đang trống (do vừa login hoặc mới cài app), tự động load
      if (gardenState.gardens.isEmpty) {
        ref.read(gardenProvider.notifier).loadGardens();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final gardenState = ref.watch(gardenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHeader(
        title: 'Vườn cây của tôi',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () => _showGardenForm(context, null),
          ),
        ],
      ),
      body: gardenState.isLoading && gardenState.gardens.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : gardenState.error != null && gardenState.gardens.isEmpty
              ? Center(child: Text('Lỗi: ${gardenState.error}'))
              : gardenState.gardens.isEmpty
                  ? Center(
                      child: Text(
                        'Bạn chưa có vườn nào.\nHãy bấm + để thêm vườn nhé!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyGrey,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(gardenProvider.notifier).loadGardens(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: gardenState.gardens.length,
                        itemBuilder: (context, index) {
                          final garden = gardenState.gardens[index];
                          return _buildGardenCard(context, garden);
                        },
                      ),
                    ),
    );
  }

  Widget _buildGardenCard(BuildContext context, GardenModel garden) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GardenDetailScreen(garden: garden)),
      ),
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
          // Anh cua vuon + Badge so luong cay
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  image: garden.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(garden.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: garden.imageUrl == null
                    ? const Icon(Icons.local_florist, size: 64, color: Colors.grey)
                    : null,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${garden.plantCount} cây',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Thong tin cua vuon
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        garden.name,
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 6),
                      if (garden.description != null && garden.description!.isNotEmpty) ...[
                        Text(
                          garden.description!,
                          style: AppTextStyles.bodyGrey,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (garden.location != null && garden.location!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                garden.location!,
                                style: AppTextStyles.bodyGrey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Nhan ... (More options)
                AppPopupMenu(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showGardenForm(context, garden);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, garden.id);
                    }
                  },
                  items: const [
                    AppPopupMenuItemData(value: 'edit', icon: Icons.edit_outlined, label: 'Sửa', color: Colors.blue),
                    AppPopupMenuItemData(value: 'delete', icon: Icons.delete_outline, label: 'Xóa', color: Colors.red, isDestructive: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ); // dong GestureDetector
}

  void _showGardenForm(BuildContext context, GardenModel? garden) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => GardenFormBottomSheet(garden: garden),
    );
  }

  void _showDeleteDialog(BuildContext context, int gardenId) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Xác nhận xóa vườn',
        content: 'Bạn có chắc chắn muốn xóa vườn này không?\nHành động này không thể hoàn tác.',
        onConfirm: () async {
          await ref.read(gardenProvider.notifier).deleteGarden(gardenId);
        },
      ),
    );
  }
}
