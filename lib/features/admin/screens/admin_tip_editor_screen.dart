import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/error_mapper.dart';
import '../../tips/providers/care_tip_provider.dart';
import '../../tips/data/care_tip_model.dart';
import '../providers/admin_tips_provider.dart';

class AdminTipEditorScreen extends ConsumerStatefulWidget {
  final CareTipModel? initialTip;

  const AdminTipEditorScreen({super.key, this.initialTip});

  @override
  ConsumerState<AdminTipEditorScreen> createState() => _AdminTipEditorScreenState();
}

class _AdminTipEditorScreenState extends ConsumerState<AdminTipEditorScreen> {
  late TextEditingController _titleController;
  late QuillController _quillController;
  
  XFile? _coverImageFile;
  String _coverImageUrl = '';
  String _selectedCategory = 'Chung';

  final List<String> _categories = ['Tưới nước', 'Bón phân', 'Phòng bệnh', 'Ánh sáng', 'Chung'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final tip = widget.initialTip;
    
    _titleController = TextEditingController(text: tip?.title ?? '');
    _coverImageUrl = tip?.imageUrl ?? '';
    _selectedCategory = tip?.category ?? 'Chung';
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }

    if (tip != null && tip.content.isNotEmpty) {
      try {
        final jsonDelta = jsonDecode(tip.content);
        _quillController = QuillController(
          document: Document.fromJson(jsonDelta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Fallback if old plain text data
        _quillController = QuillController(
          document: Document()..insert(0, tip.content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _coverImageFile = file;
        _coverImageUrl = ''; // Reset url if new file picked
      });
    }
  }

  Future<void> _saveTip() async {
    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Vui lòng nhập tiêu đề mẹo!');
      return;
    }

    setState(() => _isSaving = true);

    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    
    final data = {
      'title': _titleController.text.trim(),
      'content': contentJson,
      'imageUrl': _coverImageFile != null ? '' : _coverImageUrl,
      'category': _selectedCategory,
    };

    try {
      if (widget.initialTip != null) {
        await ref.read(careTipProvider.notifier)
            .updateTip(widget.initialTip!.id, data, imageFile: _coverImageFile);
      } else {
        await ref.read(careTipProvider.notifier)
            .createTip(data, imageFile: _coverImageFile);
      }

      // Refresh admin list to show new data immediately when popping
      try {
        await ref.read(adminTipsProvider.notifier).loadTips(silent: true);
      } catch (e) {
        // ignore
      }

      setState(() => _isSaving = false);

      if (mounted) {
        AppSnackbar.showSuccess(context, widget.initialTip != null ? 'Cập nhật thành công!' : 'Xuất bản thành công!');
        context.pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        AppSnackbar.showError(context, ErrorMapper.parseError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.initialTip != null ? 'Chỉnh sửa mẹo' : 'Mẹo mới',
          style: AppTextStyles.body.copyWith(color: Colors.black54),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveTip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(widget.initialTip != null ? 'Cập nhật' : 'Xuất bản', style: const TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: QuillSimpleToolbar(
              controller: _quillController,
              config: const QuillSimpleToolbarConfig(
                showFontFamily: false,
                showFontSize: false,
                showInlineCode: false,
                showCodeBlock: false,
                showClearFormat: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showStrikeThrough: false,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800), // Max width cho Editor
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  children: [
                    // Cover Image Area
                    GestureDetector(
                      onTap: _pickCoverImage,
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          image: _coverImageFile != null
                              ? DecorationImage(
                                  image: kIsWeb ? NetworkImage(_coverImageFile!.path) : FileImage(io.File(_coverImageFile!.path)) as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                              : (_coverImageUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(_coverImageUrl), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: (_coverImageFile == null && _coverImageUrl.isEmpty)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text('Thêm ảnh bìa', style: AppTextStyles.bodyGrey),
                                ],
                              )
                            : Container(
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.all(12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: 'Tiêu đề mẹo chăm sóc...',
                        hintStyle: TextStyle(color: Colors.black26),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Category Selection
                    Row(
                      children: [
                        Text('Danh mục: ', style: AppTextStyles.bodyGrey),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCategory = val);
                              },
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTextStyles.body))).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Quill Editor
                    QuillEditor.basic(
                      controller: _quillController,
                      config: const QuillEditorConfig(
                        placeholder: 'Bắt đầu viết nội dung...',
                        padding: EdgeInsets.only(bottom: 100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
