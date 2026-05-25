import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_header.dart';
import '../models/garden_model.dart';
import '../models/plant_model.dart';
import '../providers/plant_provider.dart';
import '../providers/garden_provider.dart';
import '../widgets/garden_form_bottom_sheet.dart';
import '../widgets/plant_form_bottom_sheet.dart';
import '../widgets/move_tree_dialog.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_model.dart';
import '../widgets/reminder_form_bottom_sheet.dart';
import 'plant_detail_screen.dart';
import '../../../core/widgets/custom_tab_switcher.dart';
import '../../../core/widgets/app_popup_menu.dart';

class GardenDetailScreen extends ConsumerStatefulWidget {
  final GardenModel garden;

  const GardenDetailScreen({super.key, required this.garden});

  @override
  ConsumerState<GardenDetailScreen> createState() => _GardenDetailScreenState();
}

class _GardenDetailScreenState extends ConsumerState<GardenDetailScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantState = ref.read(plantProvider(widget.garden.id));
      if (plantState.plants.isEmpty) {
        ref.read(plantProvider(widget.garden.id).notifier).loadPlants();
      }
      
      final reminderState = ref.read(reminderProvider(widget.garden.id));
      if (reminderState.reminders.isEmpty) {
        ref.read(reminderProvider(widget.garden.id).notifier).loadReminders();
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantProvider(widget.garden.id));
    final gardenState = ref.watch(gardenProvider);
    final currentGarden = gardenState.gardens.firstWhere(
      (g) => g.id == widget.garden.id,
      orElse: () => widget.garden,
    );
    final reminderState = ref.watch(reminderProvider(widget.garden.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHeader(
        title: currentGarden.name,
        showBackButton: true,
        actions: [
          AppPopupMenu(
            isIconWhite: true,
            onSelected: (val) {
              if (val == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => GardenFormBottomSheet(garden: currentGarden),
                );
              }
            },
            items: const [
              AppPopupMenuItemData(value: 'edit', icon: Icons.edit_outlined, label: 'Sửa', color: Colors.blue),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // === Tab Bar ===
          CustomTabSwitcher(
            tabs: const ['Danh sách cây', 'Lịch chăm sóc'],
            selectedIndex: _currentIndex,
            onTabChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),

          // === Tab Content ===
          Expanded(
            child: _currentIndex == 0
                ? _buildPlantListTab(plantState, gardenState)
                : _buildCareScheduleTab(reminderState, plantState),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantListTab(PlantState plantState, GardenState gardenState) {
    return Column(
      children: [
        // Nut Them cay
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPlantForm(context, null),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Thêm cây', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),

        // Danh sach cay
        Expanded(
          child: plantState.isLoading && plantState.plants.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : plantState.plants.isEmpty
                  ? Center(
                      child: Text(
                        'Vườn chưa có cây nào.\nBấm "+ Thêm cây" để bắt đầu!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyGrey,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(plantProvider(widget.garden.id).notifier).loadPlants(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: plantState.plants.length,
                        itemBuilder: (context, index) {
                          return _buildPlantCard(
                            plantState.plants[index],
                            gardenState.gardens,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildPlantCard(PlantModel plant, List<GardenModel> allGardens) {
    String? formattedDate;
    if (plant.datePlanted != null) {
      try {
        final date = DateTime.parse(plant.datePlanted!);
        formattedDate = DateFormat('d/M/yyyy').format(date);
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlantDetailScreen(
              plant: plant,
              garden: widget.garden,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // === Anh cay ===
            Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: plant.imageUrl != null
                  ? Image.network(plant.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.local_florist, size: 50, color: Colors.grey))
                  : const Icon(Icons.local_florist, size: 50, color: Colors.grey),
            ),

            // === Thong tin ===
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ten cay + Ten loai
                        Text(
                          plant.species != null && plant.species!.isNotEmpty
                              ? '${plant.name} (${plant.species})'
                              : plant.name,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (formattedDate != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text('Trồng $formattedDate', style: AppTextStyles.bodyGrey.copyWith(fontSize: 13)),
                            ],
                          ),
                        ],

                        // === Icon cham soc ===
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _careIcon(Icons.water_drop, 'Tưới nước', Colors.blue),
                            _careIcon(Icons.compost, 'Bón phân', Colors.brown),
                            _careIcon(Icons.shower, 'Phun sương', Colors.purple),
                            _careIcon(Icons.rotate_right, 'Xoay cây', Colors.orange),
                            _careIcon(Icons.content_cut, 'Cắt tỉa', Colors.teal),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // === Menu ··· ===
                  AppPopupMenu(
                    onSelected: (val) {
                      if (val == 'edit') _showPlantForm(context, plant);
                      if (val == 'move') _showMoveDialog(context, plant, allGardens);
                      if (val == 'delete') _showDeleteDialog(context, plant);
                    },
                    items: const [
                      AppPopupMenuItemData(value: 'edit', icon: Icons.edit_outlined, label: 'Sửa', color: Colors.blue),
                      AppPopupMenuItemData(value: 'move', icon: Icons.swap_horiz, label: 'Chuyển vườn', color: Colors.orange),
                      AppPopupMenuItemData(value: 'delete', icon: Icons.delete_outline, label: 'Xóa', color: Colors.red, isDestructive: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _careIcon(IconData icon, String tooltip, Color color) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }

  // === SHARED UI HELPERS ===

  void _showPlantForm(BuildContext context, PlantModel? plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (_) => PlantFormBottomSheet(gardenId: widget.garden.id, plant: plant),
    );
  }

  void _showMoveDialog(BuildContext context, PlantModel plant, List<GardenModel> allGardens) {
    showDialog(
      context: context,
      builder: (_) => MoveTreeDialog(plant: plant, allGardens: allGardens),
    );
  }

  void _showDeleteDialog(BuildContext context, PlantModel plant) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: 'Xác nhận xóa cây',
        content: 'Bạn có chắc chắn muốn xóa **${plant.name}** không?\nHành động này không thể hoàn tác.',
        onConfirm: () async => ref.read(plantProvider(widget.garden.id).notifier).deletePlant(plant.id),
      ),
    );
  }

  // =====================================
  // === TAB 2: LỊCH CHĂM SÓC
  // =====================================

  Widget _buildCareScheduleTab(ReminderState reminderState, PlantState plantState) {
    return Column(
      children: [
        // Button Add
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showReminderForm(context, null, null),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Thêm lịch chăm sóc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),

        Expanded(
          child: reminderState.isLoading && reminderState.reminders.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : reminderState.reminders.isEmpty
                  ? Center(child: Text('Chưa có lịch chăm sóc nào.', style: AppTextStyles.bodyGrey))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(reminderProvider(widget.garden.id).notifier).loadReminders(),
                      child: _buildReminderList(reminderState.reminders, plantState.plants),
                    ),
        ),
      ],
    );
  }

  Widget _buildReminderList(List<ReminderModel> reminders, List<PlantModel> plants) {
    // Group by type
    final grouped = <String, List<ReminderModel>>{};
    for (var r in reminders) {
      grouped.putIfAbsent(r.type, () => []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final type = grouped.keys.elementAt(index);
        final list = grouped[type]!;
        
        return Container(
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
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Row(
                children: [
                  Icon(_getIconForType(type), color: _getColorForType(type)),
                  const SizedBox(width: 12),
                  Text(_getNameForType(type), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${list.length} cây', style: AppTextStyles.bodyGrey),
                ],
              ),
              children: list.map((r) => _buildReminderItem(r, plants)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReminderItem(ReminderModel reminder, List<PlantModel> plants) {
    final plant = plants.firstWhere((p) => p.id == reminder.plantId, orElse: () => PlantModel(id: 0, gardenId: 0, name: 'Không rõ'));
    
    // Parse time
    String timeStr = reminder.triggerTime;
    try {
      final parts = reminder.triggerTime.split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      timeStr = time.format(context);
    } catch (_) {}

    // Parse repeat
    String repeatStr = '';
    try {
      if (reminder.repeatDays.contains('_')) {
        final parts = reminder.repeatDays.split('_');
        final num = parts[0];
        final unit = parts[1] == 'DAYS' ? 'ngày' : parts[1] == 'WEEKS' ? 'tuần' : 'tháng';
        repeatStr = 'Mỗi $num $unit';
      } else {
        repeatStr = reminder.repeatDays;
      }
    } catch (_) {}

    return Column(
      children: [
        Divider(color: Colors.grey.shade200, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  image: plant.imageUrl != null
                      ? DecorationImage(image: NetworkImage(plant.imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: plant.imageUrl == null
                    ? Icon(Icons.local_florist, color: Colors.grey.shade400)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plant.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('$timeStr   $repeatStr', style: AppTextStyles.bodyGrey.copyWith(fontSize: 13)),
                    if (reminder.nextExecution != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Lần tiếp theo: ${DateFormat("dd/MM/yyyy").format(DateTime.parse(reminder.nextExecution!))}',
                        style: AppTextStyles.bodyGrey.copyWith(
                          fontSize: 13,
                          color: DateTime.parse(reminder.nextExecution!).isBefore(DateTime.now().add(const Duration(days: 1))) 
                            ? Colors.red.shade400 
                            : Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppPopupMenu(
                onSelected: (val) {
                  if (val == 'edit') _showReminderForm(context, reminder, null);
                  if (val == 'delete') _showDeleteReminderDialog(context, reminder);
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
    );
  }

  void _showReminderForm(BuildContext context, ReminderModel? reminder, int? plantId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (_) => ReminderFormBottomSheet(
        gardenId: widget.garden.id,
        reminder: reminder,
        preSelectedPlantId: plantId,
      ),
    );
  }

  void _showDeleteReminderDialog(BuildContext context, ReminderModel reminder) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: 'Xác nhận xóa lịch',
        content: 'Bạn có chắc chắn muốn xóa lịch ${_getNameForType(reminder.type).toLowerCase()} không?\nHành động này không thể hoàn tác.',
        onConfirm: () async => ref.read(reminderProvider(widget.garden.id).notifier).deleteReminder(reminder.id),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'WATERING': return Icons.water_drop;
      case 'FERTILIZING': return Icons.compost;
      case 'MISTING': return Icons.shower;
      case 'ROTATING': return Icons.rotate_right;
      case 'PRUNING': return Icons.content_cut;
      default: return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'WATERING': return Colors.blue;
      case 'FERTILIZING': return Colors.brown;
      case 'MISTING': return Colors.purple;
      case 'ROTATING': return Colors.orange;
      case 'PRUNING': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _getNameForType(String type) {
    switch (type) {
      case 'WATERING': return 'Tưới nước';
      case 'FERTILIZING': return 'Bón phân';
      case 'MISTING': return 'Phun sương';
      case 'ROTATING': return 'Xoay cây';
      case 'PRUNING': return 'Cắt tỉa';
      default: return 'Khác';
    }
  }
}
