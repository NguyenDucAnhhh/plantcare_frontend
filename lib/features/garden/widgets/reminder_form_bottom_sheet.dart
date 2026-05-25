import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../models/reminder_model.dart';
import '../providers/plant_provider.dart';
import '../providers/reminder_provider.dart';

class ReminderFormBottomSheet extends ConsumerStatefulWidget {
  final int gardenId;
  final ReminderModel? reminder;
  final int? preSelectedPlantId;

  const ReminderFormBottomSheet({
    super.key,
    required this.gardenId,
    this.reminder,
    this.preSelectedPlantId,
  });

  @override
  ConsumerState<ReminderFormBottomSheet> createState() => _ReminderFormBottomSheetState();
}

class _ReminderFormBottomSheetState extends ConsumerState<ReminderFormBottomSheet> {
  int? _selectedPlantId;
  String _selectedType = 'WATERING';
  final TextEditingController _repeatCountCtrl = TextEditingController(text: '1');
  String _selectedRepeatUnit = 'DAYS';
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Lần thực hiện trước
  String _lastPerformedOption = 'NOT_DONE'; // NOT_DONE, FORGOT, TODAY, CUSTOM
  DateTime? _customLastDate;

  final Map<String, String> _typeNames = {
    'WATERING': 'Tưới nước',
    'FERTILIZING': 'Bón phân',
    'MISTING': 'Phun sương',
    'ROTATING': 'Xoay cây',
    'PRUNING': 'Cắt tỉa',
  };

  final Map<String, IconData> _typeIcons = {
    'WATERING': Icons.water_drop,
    'FERTILIZING': Icons.compost,
    'MISTING': Icons.shower,
    'ROTATING': Icons.rotate_right,
    'PRUNING': Icons.content_cut,
  };

  final Map<String, Color> _typeColors = {
    'WATERING': Colors.blue,
    'FERTILIZING': Colors.brown,
    'MISTING': Colors.purple,
    'ROTATING': Colors.orange,
    'PRUNING': Colors.teal,
  };

  final Map<String, String> _unitNames = {
    'DAYS': 'ngày',
    'WEEKS': 'tuần',
    'MONTHS': 'tháng',
  };

  @override
  void initState() {
    super.initState();
    _selectedPlantId = widget.preSelectedPlantId;

    if (widget.reminder != null) {
      final r = widget.reminder!;
      _selectedPlantId = r.plantId;
      _selectedType = r.type;

      // Parse triggerTime (HH:mm:ss)
      try {
        final parts = r.triggerTime.split(':');
        if (parts.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (_) {}

      // Parse repeatDays (e.g., 1_DAYS)
      try {
        if (r.repeatDays.contains('_')) {
          final parts = r.repeatDays.split('_');
          _repeatCountCtrl.text = parts[0];
          _selectedRepeatUnit = parts[1];
        }
      } catch (_) {}

      // Parse lastPerformed
      if (r.lastPerformed != null) {
        try {
          _customLastDate = DateTime.parse(r.lastPerformed!);
          _lastPerformedOption = 'CUSTOM';
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _repeatCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customLastDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _customLastDate = picked;
        _lastPerformedOption = 'CUSTOM';
      });
    }
  }

  /// Tính ra giá trị lastPerformed ISO string để gửi lên server
  String? _getLastPerformedIso() {
    switch (_lastPerformedOption) {
      case 'NOT_DONE':
      case 'FORGOT':
        return null;
      case 'TODAY':
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day,
            _selectedTime.hour, _selectedTime.minute).toIso8601String();
      case 'CUSTOM':
        if (_customLastDate != null) {
          return DateTime(_customLastDate!.year, _customLastDate!.month, _customLastDate!.day,
              _selectedTime.hour, _selectedTime.minute).toIso8601String();
        }
        return null;
      default:
        return null;
    }
  }

  /// Tính "Lần thực hiện tiếp theo" để hiển thị trên UI
  String _calculateNextExecution() {
    DateTime? base;

    switch (_lastPerformedOption) {
      case 'TODAY':
        base = DateTime.now();
        break;
      case 'CUSTOM':
        base = _customLastDate;
        break;
      default:
        return 'Chưa xác định';
    }

    if (base == null) return 'Chưa xác định';

    final count = int.tryParse(_repeatCountCtrl.text.trim()) ?? 1;
    DateTime next;

    switch (_selectedRepeatUnit) {
      case 'DAYS':
        next = base.add(Duration(days: count));
        break;
      case 'WEEKS':
        next = base.add(Duration(days: count * 7));
        break;
      case 'MONTHS':
        next = DateTime(base.year, base.month + count, base.day);
        break;
      default:
        return 'Chưa xác định';
    }

    // Gắn giờ trigger
    next = DateTime(next.year, next.month, next.day,
        _selectedTime.hour, _selectedTime.minute);

    return DateFormat('hh:mm a dd/MM/yyyy').format(next);
  }

  Future<void> _submit() async {
    if (_selectedPlantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn cây')),
      );
      return;
    }

    final count = _repeatCountCtrl.text.trim();
    if (count.isEmpty || int.tryParse(count) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số lặp lại hợp lệ')),
      );
      return;
    }

    final repeatStr = '${count}_$_selectedRepeatUnit';
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
    final lastPerformedIso = _getLastPerformedIso();

    final notifier = ref.read(reminderProvider(widget.gardenId).notifier);
    bool success;

    if (widget.reminder == null) {
      success = await notifier.addReminder(
        plantId: _selectedPlantId!,
        type: _selectedType,
        triggerTime: timeStr,
        repeatDays: repeatStr,
        lastPerformed: lastPerformedIso,
      );
    } else {
      success = await notifier.updateReminder(
        reminderId: widget.reminder!.id,
        type: _selectedType,
        triggerTime: timeStr,
        repeatDays: repeatStr,
        lastPerformed: lastPerformedIso,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reminder != null;
    final plantState = ref.watch(plantProvider(widget.gardenId));
    final reminderState = ref.watch(reminderProvider(widget.gardenId));

    String formattedTime = _selectedTime.format(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isEdit ? 'Cập nhật lịch chăm sóc' : 'Thêm lịch chăm sóc',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chon cay
            _buildLabel('Chọn cây'),
            _buildDropdownContainer(
              child: DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Chọn cây'),
                value: _selectedPlantId,
                items: plantState.plants.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: isEdit ? null : (val) {
                  setState(() => _selectedPlantId = val);
                },
              ),
            ),

            // Nhac nho ve
            _buildLabel('Nhắc nhở về'),
            _buildDropdownContainer(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedType,
                items: _typeNames.keys.map((k) {
                  return DropdownMenuItem(
                    value: k,
                    child: Row(
                      children: [
                        Icon(_typeIcons[k], color: _typeColors[k] ?? AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(_typeNames[k]!, style: AppTextStyles.body),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
            ),

            // Lap lai
            _buildLabel('Lặp lại'),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _repeatCountCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildDropdownContainer(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedRepeatUnit,
                      items: _unitNames.keys.map((k) {
                        return DropdownMenuItem(
                          value: k,
                          child: Text(_unitNames[k]!, style: AppTextStyles.body),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRepeatUnit = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                'Mỗi ${_repeatCountCtrl.text} ${_unitNames[_selectedRepeatUnit]}',
                style: AppTextStyles.bodyGrey.copyWith(fontSize: 13),
              ),
            ),

            // Thoi gian
            _buildLabel('Thời gian'),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(formattedTime, style: AppTextStyles.body),
              ),
            ),

            // Lan thuc hien truoc (Dropdown)
            _buildLabel(isEdit ? 'Lần thực hiện tiếp theo' : 'Lần thực hiện trước'),
            if (isEdit) ...[
              // Khi sửa: hiển thị nextExecution từ server hoặc tính lại
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.reminder?.nextExecution != null
                    ? _formatNextExecution(widget.reminder!.nextExecution!)
                    : _calculateNextExecution(),
                  style: AppTextStyles.body,
                ),
              ),
            ] else ...[
              // Khi thêm mới: dropdown
              _buildDropdownContainer(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _lastPerformedOption,
                  items: [
                    const DropdownMenuItem(value: 'NOT_DONE', child: Text('Chưa thực hiện')),
                    const DropdownMenuItem(value: 'FORGOT', child: Text('Không nhớ')),
                    const DropdownMenuItem(value: 'TODAY', child: Text('Hôm nay')),
                    DropdownMenuItem(
                      value: 'CUSTOM',
                      child: Text(
                        _customLastDate != null
                            ? DateFormat('dd/MM/yyyy').format(_customLastDate!)
                            : 'Chọn ngày...',
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val == 'CUSTOM') {
                      _pickCustomDate();
                    } else if (val != null) {
                      setState(() => _lastPerformedOption = val);
                    }
                  },
                ),
              ),

              // Hiển thị preview lần thực hiện tiếp theo
              if (_lastPerformedOption == 'TODAY' || _lastPerformedOption == 'CUSTOM')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lần tiếp theo: ${_calculateNextExecution()}',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),

            if (reminderState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(reminderState.error!, style: TextStyle(color: AppColors.error)),
              ),

            // Button submit
            AppButton(
              label: isEdit ? 'Lưu thay đổi' : 'Thêm lịch',
              isLoading: reminderState.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  String _formatNextExecution(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('hh:mm a dd/MM/yyyy').format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
