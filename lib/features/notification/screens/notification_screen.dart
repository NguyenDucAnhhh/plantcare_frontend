import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_tab_switcher.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Thông báo',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        actions: [
          if (state.unreadCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          CustomTabSwitcher(
            tabs: const ['Tất cả', 'Lịch chăm sóc', 'Cộng đồng'],
            selectedIndex: _currentIndex,
            onTabChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Expanded(
            child: state.isLoading && state.notifications.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _buildCurrentTabContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent(NotificationState state) {
    if (_currentIndex == 0) {
      return _buildList(state.notifications, context);
    } else if (_currentIndex == 1) {
      return _buildList(state.notifications.where((n) => n.type == 'REMINDER').toList(), context);
    } else {
      return _buildList(state.notifications.where((n) => n.type == 'COMMUNITY').toList(), context);
    }
  }

  Widget _buildList(List<NotificationModel> notifications, BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          'Không có thông báo nào',
          style: AppTextStyles.body.copyWith(color: AppColors.textLight),
        ),
      );
    }
    
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ProviderScope.containerOf(context).read(notificationProvider.notifier).loadNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return NotificationCard(notification: notif);
        },
      ),
    );
  }
}

class NotificationCard extends ConsumerWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Xây dựng Icon bên trái dựa trên nội dung/type
    Widget iconWidget;
    Color iconColor;
    
    final lowerTitle = notification.title.toLowerCase();
    
    if (notification.type == 'COMMUNITY' && lowerTitle.contains('thích')) {
      iconWidget = const Icon(Icons.favorite_border, color: AppColors.error);
      iconColor = AppColors.error.withValues(alpha: 0.1);
    } else if (notification.type == 'COMMUNITY' && lowerTitle.contains('bình luận')) {
      iconWidget = const Icon(Icons.chat_bubble_outline, color: Colors.blue);
      iconColor = Colors.blue.withValues(alpha: 0.1);
    } else if (notification.type == 'COMMUNITY' && (lowerTitle.contains('theo dõi') || lowerTitle.contains('follower'))) {
      iconWidget = const Icon(Icons.person_add_alt_1_outlined, color: Colors.green);
      iconColor = Colors.green.withValues(alpha: 0.1);
    } else if (notification.type == 'REMINDER') {
      iconWidget = const Icon(Icons.alarm, color: Colors.orange);
      iconColor = Colors.orange.withValues(alpha: 0.1);
    } else {
      iconWidget = const Icon(Icons.info_outline, color: AppColors.primary);
      iconColor = AppColors.primary.withValues(alpha: 0.1);
    }

    return GestureDetector(
      onTap: () {
        // Đánh dấu đã đọc
        if (!notification.isRead) {
          ref.read(notificationProvider.notifier).markAsRead(notification.id);
        }
        
        // Điều hướng
        if (notification.targetId != null) {
          if (notification.type == 'COMMUNITY' && !lowerTitle.contains('theo dõi')) {
            context.push('/post/${notification.targetId}');
          } else if (notification.type == 'COMMUNITY' && lowerTitle.contains('theo dõi')) {
            // Chuyển sang public profile của người theo dõi
            context.push('/user/${notification.targetId}');
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF0FAEC), // Nền hơi xanh nhạt cho thông báo chưa đọc
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.grey.shade200 : AppColors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            if (!notification.isRead)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon thay thế cho Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 12),
            
            // Nội dung thông báo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(color: AppColors.textDark),
                      children: [
                        TextSpan(
                          text: notification.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (notification.message.isNotEmpty)
                          TextSpan(text: ' ${notification.message}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        notification.timeAgo,
                        style: AppTextStyles.bodyGrey,
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
