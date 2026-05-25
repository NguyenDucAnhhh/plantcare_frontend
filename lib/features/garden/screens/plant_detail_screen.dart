import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/plant_model.dart';
import '../models/garden_model.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_form_bottom_sheet.dart';
import '../widgets/plant_form_bottom_sheet.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../providers/plant_provider.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/app_popup_menu.dart';

class PlantDetailScreen extends ConsumerStatefulWidget {
  final PlantModel plant;
  final GardenModel garden;

  const PlantDetailScreen({
    super.key,
    required this.plant,
    required this.garden,
  });

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  // Track current plant in case it's edited
  late PlantModel _currentPlant;

  @override
  void initState() {
    super.initState();
    _currentPlant = widget.plant;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reminderProvider(widget.garden.id).notifier).loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reminderState = ref.watch(reminderProvider(widget.garden.id));
    // Lọc chỉ lấy lịch của cây này
    final plantReminders = reminderState.reminders
        .where((r) => r.plantId == _currentPlant.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHeader(
        title: _currentPlant.name,
        showBackButton: true,
        actions: [
          AppPopupMenu(
            isIconWhite: true,
            onSelected: (val) {
              if (val == 'edit') _showEditPlant(context);
              if (val == 'delete') _showDeletePlant(context);
            },
            items: const [
              AppPopupMenuItemData(value: 'edit', icon: Icons.edit_outlined, label: 'Sửa', color: Colors.blue),
              AppPopupMenuItemData(value: 'delete', icon: Icons.delete_outline, label: 'Xóa', color: Colors.red, isDestructive: true),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================
            // ẢNH CÂY CỐ ĐỊNH
            // =====================
            Container(
              width: double.infinity,
              height: 240,
              color: const Color(0xFFF5F5F5),
              child: _currentPlant.imageUrl != null
                  ? Image.network(
                      _currentPlant.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),

            // =====================
            // THÔNG TIN CÂY
            // =====================
            _buildInfoCard(),

            const SizedBox(height: 8),

            // === TIÊU ĐỀ LỊCH CHĂM SÓC ===
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch chăm sóc',
                    style: AppTextStyles.heading2.copyWith(fontSize: 18),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddReminder(context),
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      'Thêm lịch',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // === DANH SÁCH LỊCH ===
            if (reminderState.isLoading && plantReminders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (plantReminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.alarm_off_outlined, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có lịch chăm sóc nào.',
                        style: AppTextStyles.bodyGrey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bấm "+ Thêm lịch" để đặt nhắc nhở!',
                        style: AppTextStyles.bodyGrey.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...plantReminders.map((r) => _buildReminderCard(r)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF0F7F0),
      child: Center(
        child: Icon(Icons.local_florist, size: 80, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildInfoCard() {
    String? formattedDate;
    if (_currentPlant.datePlanted != null) {
      try {
        final date = DateTime.parse(_currentPlant.datePlanted!);
        formattedDate = DateFormat('d/M/yyyy').format(date);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên cây
          Text(
            _currentPlant.name,
            style: AppTextStyles.heading2.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          // Tên khoa học
          if (_currentPlant.species != null && _currentPlant.species!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              _currentPlant.species!,
              style: AppTextStyles.bodyGrey.copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],

          // Mô tả
          if (_currentPlant.description != null && _currentPlant.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _currentPlant.description!,
              style: AppTextStyles.body.copyWith(
                color: Colors.grey.shade700,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Vườn + Vị trí
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            color: AppColors.primary,
            text: widget.garden.location != null && widget.garden.location!.isNotEmpty
                ? '${widget.garden.name} • ${widget.garden.location}'
                : widget.garden.name,
          ),

          // Ngày trồng
          if (formattedDate != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              color: AppColors.primary,
              text: 'Trồng ngày $formattedDate',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required Color color, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(fontSize: 14, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    // Parse time
    String timeStr = reminder.triggerTime;
    try {
      final parts = reminder.triggerTime.split(':');
      final tod = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      timeStr = tod.format(context);
    } catch (_) {}

    // Parse repeat
    String repeatStr = '';
    try {
      if (reminder.repeatDays.contains('_')) {
        final parts = reminder.repeatDays.split('_');
        final num = parts[0];
        final unit = parts[1] == 'DAYS' ? 'ngày' : parts[1] == 'WEEKS' ? 'tuần' : 'tháng';
        repeatStr = 'Mỗi $num $unit';
      }
    } catch (_) {}

    final icon = _getIconForType(reminder.type);
    final color = _getColorForType(reminder.type);
    final label = _getNameForType(reminder.type);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon loại lịch
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$timeStr   $repeatStr',
                    style: AppTextStyles.bodyGrey.copyWith(fontSize: 13),
                  ),
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

            // Menu sửa/xóa
            AppPopupMenu(
              onSelected: (val) {
                if (val == 'edit') _showEditReminder(context, reminder);
                if (val == 'delete') _showDeleteReminder(context, reminder);
              },
              items: const [
                AppPopupMenuItemData(value: 'edit', icon: Icons.edit_outlined, label: 'Sửa', color: Colors.blue),
                AppPopupMenuItemData(value: 'delete', icon: Icons.delete_outline, label: 'Xóa', color: Colors.red, isDestructive: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- ACTION HELPERS ---

  void _showAddReminder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (_) => ReminderFormBottomSheet(
        gardenId: widget.garden.id,
        preSelectedPlantId: _currentPlant.id,
      ),
    );
  }

  void _showEditReminder(BuildContext context, ReminderModel reminder) {
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
      ),
    );
  }

  void _showDeleteReminder(BuildContext context, ReminderModel reminder) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: 'Xác nhận xóa lịch',
        content: 'Bạn có chắc chắn muốn xóa lịch ${_getNameForType(reminder.type).toLowerCase()} không?\nHành động này không thể hoàn tác.',
        onConfirm: () async {
          await ref
              .read(reminderProvider(widget.garden.id).notifier)
              .deleteReminder(reminder.id);
        },
      ),
    );
  }

  void _showEditPlant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (_) => PlantFormBottomSheet(
        gardenId: widget.garden.id,
        plant: _currentPlant,
      ),
    ).then((_) {
      // Cập nhật lại plant nếu đã sửa
      final updatedState = ref.read(plantProvider(widget.garden.id));
      final updated = updatedState.plants.firstWhere(
        (p) => p.id == _currentPlant.id,
        orElse: () => _currentPlant,
      );
      if (mounted) setState(() => _currentPlant = updated);
    });
  }

  void _showDeletePlant(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: 'Xác nhận xóa cây',
        content: 'Bạn có chắc chắn muốn xóa **${_currentPlant.name}** không?\nHành động này không thể hoàn tác.',
        onConfirm: () async {
          await ref.read(plantProvider(widget.garden.id).notifier).deletePlant(_currentPlant.id);
          if (context.mounted) Navigator.of(context).pop();
        },
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
      case 'FERTILIZING': return const Color(0xFF8D6E63);
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
