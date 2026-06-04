import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_bottom_sheet_form.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/error_mapper.dart';
import '../models/garden_model.dart';
import '../providers/garden_provider.dart';

class GardenFormBottomSheet extends ConsumerStatefulWidget {
  final GardenModel? garden; // Neu null -> Them moi. Neu co -> Cap nhat

  const GardenFormBottomSheet({super.key, this.garden});

  @override
  ConsumerState<GardenFormBottomSheet> createState() => _GardenFormBottomSheetState();
}

class _GardenFormBottomSheetState extends ConsumerState<GardenFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locCtrl;

  XFile? _localImageFile;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.garden?.name ?? '');
    _descCtrl = TextEditingController(text: widget.garden?.description ?? '');
    _locCtrl = TextEditingController(text: widget.garden?.location ?? '');
    _currentImageUrl = widget.garden?.imageUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _localImageFile = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isUpdate = widget.garden != null;
    final notifier = ref.read(gardenProvider.notifier);

    try {
      if (isUpdate) {
        await notifier.updateGarden(
          id: widget.garden!.id,
          name: _nameCtrl.text.trim(),
          location: _locCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          imageFile: _localImageFile,
          currentImageUrl: _currentImageUrl,
        );
        if (mounted) AppSnackbar.showSuccess(context, 'Cập nhật vườn thành công');
      } else {
        await notifier.createGarden(
          name: _nameCtrl.text.trim(),
          location: _locCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          imageFile: _localImageFile,
        );
        if (mounted) AppSnackbar.showSuccess(context, 'Thêm vườn mới thành công');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, ErrorMapper.parseError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.garden != null;
    final gardenState = ref.watch(gardenProvider);

    return CustomBottomSheetForm(
      title: isUpdate ? 'Cập nhật vườn' : 'Thêm vườn mới',
      actionLabel: isUpdate ? 'Lưu thay đổi' : 'Thêm vườn',
      onActionPressed: _submitForm,
      isActionLoading: gardenState.isLoading,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ten vuon
            _buildLabel('Tên vườn *'),
            _buildTextField(
              controller: _nameCtrl,
              hint: 'VD: Vườn ban công',
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên vườn' : null,
            ),

            // Mo ta
            _buildLabel('Mô tả'),
            _buildTextField(
              controller: _descCtrl,
              hint: 'Mô tả về vườn...',
              maxLines: 3,
            ),

            // Vi tri
            _buildLabel('Vị trí'),
            _buildTextField(
              controller: _locCtrl,
              hint: 'VD: Ban công tầng 2',
            ),

            // Anh vuon
            _buildLabel('Ảnh vườn'),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
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
                clipBehavior: Clip.antiAlias,
                child: _buildImagePreview(),
              ),
            ),
            
            if (gardenState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  gardenState.error!,
                  style: TextStyle(color: AppColors.error),
                ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_localImageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: kIsWeb ? NetworkImage(_localImageFile!.path) : FileImage(io.File(_localImageFile!.path)) as ImageProvider,
            fit: BoxFit.cover,
          ),
          _buildClearImageIcon(),
        ],
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(_currentImageUrl!, fit: BoxFit.cover),
          _buildClearImageIcon(),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('Chọn ảnh vườn', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          Text('Tối đa 5MB', style: AppTextStyles.bodyGrey.copyWith(fontSize: 12)),
        ],
      );
    }
  }

  Widget _buildClearImageIcon() {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _localImageFile = null;
            _currentImageUrl = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
