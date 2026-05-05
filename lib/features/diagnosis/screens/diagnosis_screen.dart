import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_client.dart';

class DiagnosisScreen extends ConsumerStatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  XFile? _selectedImage;
  Map<String, dynamic>? _result;

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80, // Giam dung luong anh
      maxWidth: 1024,
    );
    if (image == null) return;

    setState(() {
      _selectedImage = image;
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final dio = ApiClient.instance;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: image.name),
      });
      final response = await dio.post('/api/diagnosis/analyze', data: formData);
      setState(() {
        _result = response.data;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi phân tích: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _result = null;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Chẩn đoán bệnh AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/diagnosis/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === KHU VUC CHON ANH ===
            if (_selectedImage == null) _buildPickerCard(),
            if (_selectedImage != null) _buildSelectedImageCard(),

            const SizedBox(height: 16),

            // === KET QUA PHAN TICH ===
            if (_isAnalyzing) _buildLoadingCard(),
            if (_result != null) _buildResultCard(_result!),

            const SizedBox(height: 16),

            // === MEO CHUP ANH ===
            if (_result == null && !_isAnalyzing) _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  CARD CHON ANH (Khi chua chon)
  // ============================================================
  Widget _buildPickerCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('🔬', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Chọn hình ảnh để chẩn đoán',
              style: AppTextStyles.heading3.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Chụp ảnh hoặc tải lên hình ảnh lá cây bị bệnh',
              style: AppTextStyles.bodyGrey.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickAndAnalyze(ImageSource.camera),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_outlined, color: Colors.blue.shade600, size: 32),
                        const SizedBox(height: 8),
                        Text('Chụp ảnh', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickAndAnalyze(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.upload_outlined, color: Colors.blue.shade600, size: 32),
                        const SizedBox(height: 8),
                        Text('Tải lên', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  HIEN THI ANH DA CHON
  // ============================================================
  Widget _buildSelectedImageCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImage!.path),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Chọn ảnh khác'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  DANG PHAN TICH (Loading)
  // ============================================================
  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'AI đang phân tích hình ảnh...',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Quá trình này có thể mất 5-15 giây',
            style: AppTextStyles.bodyGrey.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  KET QUA PHAN TICH
  // ============================================================
  Widget _buildResultCard(Map<String, dynamic> result) {
    final confidence = (result['confidenceScore'] ?? 0).toDouble();
    final Color severityColor = confidence >= 80
        ? Colors.red.shade600
        : confidence >= 50
            ? Colors.orange.shade700
            : Colors.green.shade600;
    final String severityLabel = confidence >= 80
        ? 'Nghiêm trọng'
        : confidence >= 50
            ? 'Trung bình'
            : 'Nhẹ';

    return Column(
      children: [
        // Badge ket qua
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.8), const Color(0xFF43A047)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                'Phân tích hoàn tất!',
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Độ chính xác: ${confidence.toStringAsFixed(0)}%',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chi tiet ket qua
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ten cay + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result['plantName'] ?? 'Không xác định',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result['diseaseName'] ?? 'Không xác định',
                            style: AppTextStyles.heading3.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        severityLabel,
                        style: TextStyle(color: severityColor, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Nguyen nhan
                _buildInfoRow(Icons.info_outline, 'Nguyên nhân', result['cause'] ?? 'Không xác định'),
                const SizedBox(height: 16),

                // Cach chua
                _buildInfoRow(Icons.healing_outlined, 'Cách chữa', result['treatment'] ?? 'Không xác định'),
                const SizedBox(height: 20),

                // Nut chuan doan lai
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Chẩn đoán ảnh khác'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.bodyGrey.copyWith(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  MEO CHUP ANH CARD
  // ============================================================
  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Mẹo chụp ảnh tốt:',
                style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Chụp ở nơi có ánh sáng đầy đủ'),
          const SizedBox(height: 8),
          _buildTipItem('Tập trung vào phần lá bị bệnh'),
          const SizedBox(height: 8),
          _buildTipItem('Giữ camera ổn định và rõ nét'),
          const SizedBox(height: 8),
          _buildTipItem('Chụp từ nhiều góc độ khác nhau'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Icon(Icons.circle, size: 6, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.blue.shade800, fontSize: 14)),
        ),
      ],
    );
  }
}
