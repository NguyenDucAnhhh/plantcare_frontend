import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/garden_provider.dart';
import '../models/garden_model.dart';
import '../widgets/garden_form_bottom_sheet.dart';
import '../widgets/confirm_delete_dialog.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> {
  @override
  Widget build(BuildContext context) {
    final gardenState = ref.watch(gardenProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Vườn cây của tôi',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    ),
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showGardenForm(context, garden);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, garden.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGardenForm(BuildContext context, GardenModel? garden) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GardenFormBottomSheet(garden: garden),
    );
  }

  void _showDeleteDialog(BuildContext context, int gardenId) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Xác nhận xóa vườn',
        content: 'Bạn có chắc chắn muốn xóa vườn này không?\nHành động này không thể hoàn tác.',
        onConfirm: () {
          ref.read(gardenProvider.notifier).deleteGarden(gardenId);
        },
      ),
    );
  }
}
