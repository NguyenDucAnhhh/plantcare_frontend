import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';
import '../models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationState {
  final bool isLoading;
  final String? error;
  final List<NotificationModel> notifications;

  NotificationState({
    this.isLoading = false,
    this.error,
    this.notifications = const [],
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    bool? isLoading,
    String? error,
    List<NotificationModel>? notifications,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Error will be cleared if not explicitly passed
      notifications: notifications ?? this.notifications,
    );
  }
}

final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(notificationRepositoryProvider));
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription? _msgSubscription;

  NotificationNotifier(this._repository) : super(NotificationState()) {
    loadNotifications();
    // Tự động tải lại danh sách khi nhận được thông báo mới qua Firebase
    _msgSubscription = FirebaseMessaging.onMessage.listen((_) {
      loadNotifications();
    });
  }

  @override
  void dispose() {
    _msgSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final notifications = await _repository.getMyNotifications();

      state = state.copyWith(isLoading: false, notifications: notifications);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(int id) async {
    // Optimistic UI update
    final previousNotifications = state.notifications;
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    
    state = state.copyWith(notifications: updatedNotifications);

    try {
      await _repository.markAsRead(id);
    } catch (e) {
      // Revert if failed
      state = state.copyWith(notifications: previousNotifications, error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    final previousNotifications = state.notifications;
    final updatedNotifications = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    
    state = state.copyWith(notifications: updatedNotifications);

    try {
      await _repository.markAllAsRead();
    } catch (e) {
      state = state.copyWith(notifications: previousNotifications, error: e.toString());
    }
  }
}
