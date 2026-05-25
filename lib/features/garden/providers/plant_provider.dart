import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plant_repository.dart';
import '../models/plant_model.dart';

class PlantState {
  final bool isLoading;
  final String? error;
  final List<PlantModel> plants;

  PlantState({
    this.isLoading = false,
    this.error,
    this.plants = const [],
  });

  PlantState copyWith({
    bool? isLoading,
    String? error,
    List<PlantModel>? plants,
    bool clearError = false,
  }) {
    return PlantState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      plants: plants ?? this.plants,
    );
  }
}

class PlantNotifier extends StateNotifier<PlantState> {
  final PlantRepository _repository;
  final int gardenId;

  PlantNotifier(this._repository, this.gardenId) : super(PlantState()) {
    loadPlants();
  }

  Future<void> loadPlants() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final plants = await _repository.getPlantsByGarden(gardenId);
      state = state.copyWith(isLoading: false, plants: plants);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addPlant({
    required String name,
    String? species,
    String? description,
    String? datePlanted,
    String? imagePath,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      String? imageUrl;
      if (imagePath != null) {
        imageUrl = await _repository.uploadPlantImage(imagePath);
      }
      final newPlant = PlantModel(
        id: 0,
        name: name,
        species: species,
        description: description,
        imageUrl: imageUrl,
        datePlanted: datePlanted,
        gardenId: gardenId,
      );
      final created = await _repository.addPlant(gardenId, newPlant);
      state = state.copyWith(isLoading: false, plants: [created, ...state.plants]);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePlant({
    required int plantId,
    required String name,
    String? species,
    String? description,
    String? datePlanted,
    String? imagePath,
    String? currentImageUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      String? imageUrl = currentImageUrl;
      if (imagePath != null && !imagePath.startsWith('http')) {
        imageUrl = await _repository.uploadPlantImage(imagePath);
      }
      final updated = PlantModel(
        id: plantId,
        name: name,
        species: species,
        description: description,
        imageUrl: imageUrl,
        datePlanted: datePlanted,
        gardenId: gardenId,
      );
      final result = await _repository.updatePlant(plantId, updated);
      final updatedList = state.plants.map((p) => p.id == plantId ? result : p).toList();
      state = state.copyWith(isLoading: false, plants: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deletePlant(int plantId) async {
    // Optimistic delete
    final previousList = List<PlantModel>.from(state.plants);
    final updatedList = state.plants.where((p) => p.id != plantId).toList();
    state = state.copyWith(plants: updatedList, clearError: true);
    try {
      await _repository.deletePlant(plantId);
      return true;
    } catch (e) {
      state = state.copyWith(plants: previousList, error: 'Xóa cây thất bại: $e');
      return false;
    }
  }

  Future<bool> movePlant(int plantId, int targetGardenId) async {
    // Optimistic: xoa cay khoi vuon hien tai ngay lap tuc
    final previousList = List<PlantModel>.from(state.plants);
    final updatedList = state.plants.where((p) => p.id != plantId).toList();
    state = state.copyWith(plants: updatedList, clearError: true);
    try {
      await _repository.movePlant(plantId, targetGardenId);
      return true;
    } catch (e) {
      state = state.copyWith(plants: previousList, error: 'Chuyển cây thất bại: $e');
      return false;
    }
  }
}

final plantRepositoryProvider = Provider((ref) => PlantRepository());

// Provider nhan gardenId lam tham so
final plantProvider = StateNotifierProvider.family<PlantNotifier, PlantState, int>(
  (ref, gardenId) => PlantNotifier(ref.watch(plantRepositoryProvider), gardenId),
);
