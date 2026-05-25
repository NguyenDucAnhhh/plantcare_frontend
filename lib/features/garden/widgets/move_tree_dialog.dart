import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/plant_model.dart';
import '../models/garden_model.dart';
import '../providers/plant_provider.dart';

class MoveTreeDialog extends ConsumerStatefulWidget {
  final PlantModel plant;
  final List<GardenModel> allGardens; // Danh sach tat ca vuon de chon

  const MoveTreeDialog({
    super.key,
    required this.plant,
    required this.allGardens,
  });

  @override
  ConsumerState<MoveTreeDialog> createState() => _MoveTreeDialogState();
}

class _MoveTreeDialogState extends ConsumerState<MoveTreeDialog> {
  int? _selectedGardenId;

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantProvider(widget.plant.gardenId));

    // Loc ra cac vuon khac (khong phai vuon hien tai)
    final otherGardens = widget.allGardens
        .where((g) => g.id != widget.plant.gardenId)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chuyển cây', style: AppTextStyles.heading2),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Chọn vườn đích', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // Dropdown chon vuon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedGardenId,
                  hint: Text('Chọn vườn đích', style: AppTextStyles.bodyGrey),
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  items: otherGardens.map((g) {
                    return DropdownMenuItem<int>(
                      value: g.id,
                      child: Text(g.name),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedGardenId = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedGardenId == null || plantState.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(plantProvider(widget.plant.gardenId).notifier)
                            .movePlant(widget.plant.id, _selectedGardenId!);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chuyển cây thành công!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: plantState.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Chuyển cây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
