import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_bottom_sheet_form.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/error_mapper.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../../profile/providers/profile_provider.dart';

class PostFormBottomSheet extends ConsumerStatefulWidget {
  final PostModel? post; // If null => Create, else => Edit

  const PostFormBottomSheet({super.key, this.post});

  @override
  ConsumerState<PostFormBottomSheet> createState() => _PostFormBottomSheetState();
}

class _PostFormBottomSheetState extends ConsumerState<PostFormBottomSheet> {
  late TextEditingController _contentController;
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post?.content ?? '');
    if (widget.post != null) {
      _existingImageUrls = List.from(widget.post!.imageUrls);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length + _existingImageUrls.length >= 4) {
      if (mounted) {
        AppSnackbar.showError(context, 'Chỉ được chọn tối đa 4 ảnh');
      }
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          int remainingSlots = 4 - _existingImageUrls.length - _selectedImages.length;
          for (var i = 0; i < images.length && i < remainingSlots; i++) {
            _selectedImages.add(File(images[i].path));
          }
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      final isEdit = widget.post != null;
      if (isEdit) {
        await ref.read(postProvider.notifier).updatePost(
          widget.post!.id, 
          _contentController.text,
          newImages: _selectedImages,
          existingImageUrls: _existingImageUrls,
        );
      } else {
        await ref.read(postProvider.notifier).createPost(
          _contentController.text,
          images: _selectedImages,
        );
        ref.read(postProvider.notifier).loadPosts();
      }

      // Refresh profile
      ref.read(profileProvider.notifier).loadProfileData();

      if (mounted) {
        AppSnackbar.showSuccess(context, isEdit ? 'Cập nhật thành công' : 'Đăng bài thành công');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, ErrorMapper.parseError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.post != null;

    return CustomBottomSheetForm(
      title: isEdit ? 'Chỉnh sửa bài đăng' : 'Tạo bài đăng',
      actionLabel: isEdit ? 'Lưu bài đăng' : 'Đăng bài',
      onActionPressed: _submit,
      isActionLoading: _isLoading,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 4,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: isEdit ? 'Nội dung bài đăng...' : 'Bạn đang nghĩ gì về vườn cây của mình?',
                  hintStyle: AppTextStyles.bodyGrey,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 16),

            // Image Picker Box
            if (_existingImageUrls.isEmpty && _selectedImages.isEmpty)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textLight, style: BorderStyle.solid), 
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.image_outlined, color: AppColors.textGrey, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Thêm hình ảnh (tối đa 4)',
                        style: AppTextStyles.bodyGrey.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...List.generate(_existingImageUrls.length, (index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _existingImageUrls[index],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.white, size: 20),
                                onPressed: () => _removeExistingImage(index),
                              ),
                            ),
                          ],
                        );
                      }),
                      ...List.generate(_selectedImages.length, (index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.white, size: 20),
                                onPressed: () => _removeSelectedImage(index),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (_existingImageUrls.length + _selectedImages.length < 4)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.add_photo_alternate, color: AppColors.textGrey),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Tips section (Only for create)
            if (!isEdit)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text('Mẹo viết bài hay:', style: AppTextStyles.heading3.copyWith(color: AppColors.accentBlue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Chia sẻ kinh nghiệm thực tế của bạn'),
                    _buildTip('Thêm hình ảnh minh họa rõ ràng'),
                    _buildTip('Sử dụng hashtag để dễ tìm kiếm'),
                  ],
                ),
              ),

        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.accentBlue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTextStyles.body.copyWith(color: AppColors.accentBlue)),
          ),
        ],
      ),
    );
  }
}
