import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/care_tip_model.dart';
import '../data/care_tip_repository.dart';

class CareTipState {
  final List<CareTipModel> tips;
  final bool isLoading;
  final String? error;
  
  // Filters
  final String searchQuery;
  final String? selectedCategory;

  CareTipState({
    this.tips = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
  });

  CareTipState copyWith({
    List<CareTipModel>? tips,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return CareTipState(
      tips: tips ?? this.tips,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }

  // Lọc list dựa trên state
  List<CareTipModel> get filteredTips {
    return tips.where((tip) {
      final matchSearch = searchQuery.isEmpty || 
          tip.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchCategory = selectedCategory == null || 
          selectedCategory == 'Tất cả' ||
          tip.category == selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }
}

final careTipProvider = StateNotifierProvider<CareTipNotifier, CareTipState>((ref) {
  final repository = ref.watch(careTipRepositoryProvider);
  return CareTipNotifier(repository);
});

class CareTipNotifier extends StateNotifier<CareTipState> {
  final CareTipRepository _repository;

  CareTipNotifier(this._repository) : super(CareTipState()) {
    loadTips();
  }

  Future<void> loadTips() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tips = await _repository.getAllCareTips();
      state = state.copyWith(isLoading: false, tips: tips);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? category) {
    if (category == 'Tất cả') {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  // Admin Actions
  Future<bool> createTip(Map<String, dynamic> data, {XFile? imageFile}) async {
    try {
      if (imageFile != null) {
        final uploadedUrl = await _repository.uploadImage(imageFile);
        if (uploadedUrl != null) {
          data['imageUrl'] = uploadedUrl;
        }
      }
      final newTip = await _repository.createCareTip(data);
      state = state.copyWith(tips: [newTip, ...state.tips]);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateTip(int id, Map<String, dynamic> data, {XFile? imageFile}) async {
    try {
      if (imageFile != null) {
        final uploadedUrl = await _repository.uploadImage(imageFile);
        if (uploadedUrl != null) {
          data['imageUrl'] = uploadedUrl;
        }
      }
      final updatedTip = await _repository.updateCareTip(id, data);
      state = state.copyWith(
        tips: state.tips.map((t) => t.id == id ? updatedTip : t).toList(),
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteTip(int id) async {
    try {
      await _repository.deleteCareTip(id);
      state = state.copyWith(
        tips: state.tips.where((t) => t.id != id).toList(),
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
