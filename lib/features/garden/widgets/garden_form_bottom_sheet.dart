import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
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

  String? _localImagePath;
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
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _localImagePath = image.path;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isUpdate = widget.garden != null;
    final notifier = ref.read(gardenProvider.notifier);

    bool success = false;
    if (isUpdate) {
      success = await notifier.updateGarden(
        id: widget.garden!.id,
        name: _nameCtrl.text.trim(),
        location: _locCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imagePath: _localImagePath,
        currentImageUrl: _currentImageUrl,
      );
    } else {
      success = await notifier.createGarden(
        name: _nameCtrl.text.trim(),
        location: _locCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imagePath: _localImagePath,
      );
    }

    if (success && mounted) {
      Navigator.pop(context); // Dong bottom sheet sau khi thanh cong
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.garden != null;
    final gardenState = ref.watch(gardenProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, // Day ui len khi ban phim mo
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tieu de + Nut Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isUpdate ? 'Cập nhật vườn' : 'Thêm vườn mới',
                    style: AppTextStyles.heading2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ten vuon
              _buildLabel('Tên vườn *'),
              _buildTextField(
                controller: _nameCtrl,
                hint: isUpdate ? 'VD: Vườn ban công' : 'VD: Vườn ban công',
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
              const SizedBox(height: 8),
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
              const SizedBox(height: 24),

              if (gardenState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    gardenState.error!,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                  ),
                ),

              // Nut submit
              AppButton(
                label: isUpdate ? 'Cập nhật vườn' : 'Thêm vườn',
                isLoading: gardenState.isLoading,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
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
    if (_localImagePath != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          kIsWeb
              ? Image.network(_localImagePath!, fit: BoxFit.cover)
              : Image.file(File(_localImagePath!), fit: BoxFit.cover),
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
            _localImagePath = null;
            _currentImageUrl = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
