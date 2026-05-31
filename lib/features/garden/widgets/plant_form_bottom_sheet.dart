import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_bottom_sheet_form.dart';
import '../models/plant_model.dart';
import '../providers/plant_provider.dart';

class PlantFormBottomSheet extends ConsumerStatefulWidget {
  final int gardenId;
  final PlantModel? plant; // null = Them moi, co gia tri = Chinh sua

  const PlantFormBottomSheet({
    super.key,
    required this.gardenId,
    this.plant,
  });

  @override
  ConsumerState<PlantFormBottomSheet> createState() => _PlantFormBottomSheetState();
}

class _PlantFormBottomSheetState extends ConsumerState<PlantFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _speciesCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _dateCtrl;

  String? _localImagePath;
  String? _currentImageUrl;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.plant?.name ?? '');
    _speciesCtrl = TextEditingController(text: widget.plant?.species ?? '');
    _descCtrl = TextEditingController(text: widget.plant?.description ?? '');
    _currentImageUrl = widget.plant?.imageUrl;

    if (widget.plant?.datePlanted != null) {
      _selectedDate = DateTime.tryParse(widget.plant!.datePlanted!);
      _dateCtrl = TextEditingController(
        text: _selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
            : '',
      );
    } else {
      _dateCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => _localImagePath = image.path);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(plantProvider(widget.gardenId).notifier);
    final datePlantedIso = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : null;

    bool success;
    if (widget.plant != null) {
      success = await notifier.updatePlant(
        plantId: widget.plant!.id,
        name: _nameCtrl.text.trim(),
        species: _speciesCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        datePlanted: datePlantedIso,
        imagePath: _localImagePath,
        currentImageUrl: _currentImageUrl,
      );
    } else {
      success = await notifier.addPlant(
        name: _nameCtrl.text.trim(),
        species: _speciesCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        datePlanted: datePlantedIso,
        imagePath: _localImagePath,
      );
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plant != null;
    final plantState = ref.watch(plantProvider(widget.gardenId));

    return CustomBottomSheetForm(
      title: isEdit ? 'Chỉnh sửa cây' : 'Thêm cây mới',
      actionLabel: isEdit ? 'Lưu thay đổi' : 'Thêm cây',
      onActionPressed: _submit,
      isActionLoading: plantState.isLoading,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anh cay
            _buildLabel('Ảnh cây'),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _pickImage,
              child: _buildImagePicker(isEdit),
            ),

            // Ten cay
            _buildLabel('Tên cây *'),
            _buildTextField(
              controller: _nameCtrl,
              hint: 'VD: Cà chua cherry',
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên cây' : null,
            ),

            // Loai cay
            _buildLabel('Loại cây'),
            _buildTextField(
              controller: _speciesCtrl,
              hint: 'VD: Cà chua',
            ),

            // Ngay trong
            _buildLabel('Ngày trồng'),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _dateCtrl,
                  hint: '',
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                ),
              ),
            ),

            // Mo ta
            _buildLabel('Mô tả'),
            _buildTextField(
              controller: _descCtrl,
              hint: 'Mô tả về cây của bạn...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            if (plantState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(plantState.error!, style: TextStyle(color: AppColors.error)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isEdit) {
    final hasLocalImage = _localImagePath != null;
    final hasRemoteImage = _currentImageUrl != null && _currentImageUrl!.isNotEmpty;

    if (hasLocalImage || hasRemoteImage) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: hasLocalImage
                  ? (kIsWeb
                      ? Image.network(_localImagePath!, fit: BoxFit.cover)
                      : Image.file(File(_localImagePath!), fit: BoxFit.cover))
                  : Image.network(_currentImageUrl!, fit: BoxFit.cover),
            ),
          ),
          // Nut xoa anh
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() {
                _localImagePath = null;
                _currentImageUrl = null;
              }),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          // Nut thay anh (chi hien khi dang chinh sua)
          if (isEdit)
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('Chọn ảnh cây', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          Text('Tối đa 5MB', style: AppTextStyles.bodyGrey.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyGrey,
        filled: true,
        fillColor: Colors.grey.shade100,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
