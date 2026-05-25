import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reminder_repository.dart';
import '../models/reminder_model.dart';

class ReminderState {
  final bool isLoading;
  final String? error;
  final List<ReminderModel> reminders;

  ReminderState({
    this.isLoading = false,
    this.error,
    this.reminders = const [],
  });

  ReminderState copyWith({
    bool? isLoading,
    String? error,
    List<ReminderModel>? reminders,
    bool clearError = false,
  }) {
    return ReminderState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      reminders: reminders ?? this.reminders,
    );
  }
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ReminderRepository _repository;
  final int gardenId;

  ReminderNotifier(this._repository, this.gardenId) : super(ReminderState()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final reminders = await _repository.getRemindersByGarden(gardenId);
      state = state.copyWith(isLoading: false, reminders: reminders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addReminder({
    required int plantId,
    required String type,
    required String triggerTime,
    required String repeatDays,
    String? lastPerformed,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = {
        'type': type,
        'triggerTime': triggerTime,
        'repeatDays': repeatDays,
        'lastPerformed': lastPerformed,
      };
      final created = await _repository.createReminder(plantId, data);
      state = state.copyWith(
        isLoading: false,
        reminders: [created, ...state.reminders],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateReminder({
    required int reminderId,
    required String type,
    required String triggerTime,
    required String repeatDays,
    String? lastPerformed,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = {
        'type': type,
        'triggerTime': triggerTime,
        'repeatDays': repeatDays,
        'lastPerformed': lastPerformed,
      };
      final updated = await _repository.updateReminder(reminderId, data);
      final updatedList = state.reminders.map((r) => r.id == reminderId ? updated : r).toList();
      state = state.copyWith(isLoading: false, reminders: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> toggleReminder(int reminderId) async {
    final previousList = List<ReminderModel>.from(state.reminders);
    final updatedList = state.reminders.map((r) {
      if (r.id == reminderId) {
        return ReminderModel(
          id: r.id,
          type: r.type,
          triggerTime: r.triggerTime,
          repeatDays: r.repeatDays,
          isActive: !r.isActive,
          plantId: r.plantId,
        );
      }
      return r;
    }).toList();
    state = state.copyWith(reminders: updatedList, clearError: true);

    try {
      await _repository.toggleReminder(reminderId);
      return true;
    } catch (e) {
      state = state.copyWith(reminders: previousList, error: 'Lỗi khi thay đổi trạng thái');
      return false;
    }
  }

  Future<bool> deleteReminder(int reminderId) async {
    final previousList = List<ReminderModel>.from(state.reminders);
    final updatedList = state.reminders.where((r) => r.id != reminderId).toList();
    state = state.copyWith(reminders: updatedList, clearError: true);

    try {
      await _repository.deleteReminder(reminderId);
      return true;
    } catch (e) {
      state = state.copyWith(reminders: previousList, error: 'Xóa thất bại: $e');
      return false;
    }
  }
}

final reminderRepositoryProvider = Provider((ref) => ReminderRepository());

final reminderProvider = StateNotifierProvider.family<ReminderNotifier, ReminderState, int>(
  (ref, gardenId) => ReminderNotifier(ref.watch(reminderRepositoryProvider), gardenId),
);
