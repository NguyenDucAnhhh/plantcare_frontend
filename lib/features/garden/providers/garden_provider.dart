import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/garden_repository.dart';
import '../models/garden_model.dart';

class GardenState {
  final bool isLoading;
  final String? error;
  final List<GardenModel> gardens;

  GardenState({
    this.isLoading = false,
    this.error,
    this.gardens = const [],
  });

  GardenState copyWith({
    bool? isLoading,
    String? error,
    List<GardenModel>? gardens,
    bool clearError = false,
  }) {
    return GardenState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      gardens: gardens ?? this.gardens,
    );
  }
}

class GardenNotifier extends StateNotifier<GardenState> {
  final GardenRepository _repository;

  GardenNotifier(this._repository) : super(GardenState()) {
    loadGardens();
  }

  Future<void> loadGardens() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final gardens = await _repository.getMyGardens();
      state = state.copyWith(isLoading: false, gardens: gardens);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createGarden({
    required String name,
    String? location,
    String? description,
    XFile? imageFile,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _repository.uploadGardenImage(imageFile);
      }

      final newGarden = GardenModel(
        id: 0,
        name: name,
        location: location,
        description: description,
        imageUrl: imageUrl,
      );

      final created = await _repository.createGarden(newGarden);
      state = state.copyWith(
        isLoading: false,
        gardens: [created, ...state.gardens],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<bool> updateGarden({
    required int id,
    required String name,
    String? location,
    String? description,
    XFile? imageFile,
    String? currentImageUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      String? imageUrl = currentImageUrl;
      // Neu chon anh moi tu may, thuc hien upload
      if (imageFile != null) {
        imageUrl = await _repository.uploadGardenImage(imageFile);
      }

      final updatedGarden = GardenModel(
        id: id,
        name: name,
        location: location,
        description: description,
        imageUrl: imageUrl,
      );

      final result = await _repository.updateGarden(id, updatedGarden);

      // Cap nhat list hien tai
      final updatedList = state.gardens.map((g) {
        return g.id == id ? result : g;
      }).toList();

      state = state.copyWith(isLoading: false, gardens: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<bool> deleteGarden(int id) async {
    // === OPTIMISTIC DELETE ===
    // Xoa ngay khoi danh sach UI TRUOC khi goi API
    // -> Nguoi dung thay ket qua tuc thi, khong can cho
    final previousList = List<GardenModel>.from(state.gardens);
    final updatedList = state.gardens.where((g) => g.id != id).toList();
    state = state.copyWith(gardens: updatedList, clearError: true);

    try {
      await _repository.deleteGarden(id);
      return true;
    } catch (e) {
      // Neu API loi, khoi phuc lai danh sach cu de nguoi dung biet co loi xay ra
      state = state.copyWith(gardens: previousList);
      rethrow;
    }
  }

  void updatePlantCountOnMove(int fromGardenId, int toGardenId) {
    state = state.copyWith(
      gardens: state.gardens.map((g) {
        if (g.id == fromGardenId) {
          return g.copyWith(plantCount: g.plantCount - 1);
        }
        if (g.id == toGardenId) {
          return g.copyWith(plantCount: g.plantCount + 1);
        }
        return g;
      }).toList(),
    );
  }

  void updateSinglePlantCount(int gardenId, {required bool isIncrement}) {
    state = state.copyWith(
      gardens: state.gardens.map((g) {
        if (g.id == gardenId) {
          return g.copyWith(
            plantCount: isIncrement ? g.plantCount + 1 : g.plantCount - 1,
          );
        }
        return g;
      }).toList(),
    );
  }
}

final gardenRepositoryProvider = Provider((ref) => GardenRepository());

final gardenProvider = StateNotifierProvider<GardenNotifier, GardenState>((ref) {
  return GardenNotifier(ref.watch(gardenRepositoryProvider));
});
