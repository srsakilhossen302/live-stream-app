import 'package:get/get.dart';
import '../model/notification_model.dart';

class NotificationController extends GetxController {
  // Filter: 'all', 'trades', 'live'
  final selectedFilter = 'all'.obs;

  final notifications = <NotificationModel>[
    const NotificationModel(
      id: '1',
      type: NotificationType.tradeOffer,
      title: 'TRADE OFFER',
      message: 'New Trade Offer from @Alex_Vault for your Chrono-Master V2.',
      timeAgo: '2m ago',
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop',
    ),
    const NotificationModel(
      id: '2',
      type: NotificationType.liveAlert,
      title: 'LIVE ALERT',
      message: "Julian Voss is LIVE now with 'Chrome Abstract #04'.",
      timeAgo: '15m ago',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop',
    ),
    const NotificationModel(
      id: '3',
      type: NotificationType.outbid,
      title: 'OUTBID ALERT',
      message: "You've been outbid on 'Crystalline Form #042'.",
      timeAgo: '1h ago',
      currentBid: '\$14,500',
    ),
    const NotificationModel(
      id: '4',
      type: NotificationType.security,
      title: 'SECURITY',
      message: 'Security Update: Your 2FA is active.',
      timeAgo: '4h ago',
      isRead: true,
    ),
  ].obs;

  final recommended = <RecommendedItemModel>[
    const RecommendedItemModel(
      id: 'r1',
      imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1000&auto=format&fit=crop',
      tag: 'TRENDING NOW',
      title: 'Etheric Sculptures Series',
      description: 'Based on your activity in Trades, you might like this upcoming drop by Studio Void.',
      actionLabel: 'Explore Collection',
    ),
  ].obs;

  List<NotificationModel> get filteredNotifications {
    switch (selectedFilter.value) {
      case 'trades':
        return notifications.where((n) => n.type == NotificationType.tradeOffer).toList();
      case 'live':
        return notifications.where((n) => n.type == NotificationType.liveAlert).toList();
      default:
        return notifications;
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void setFilter(String filter) => selectedFilter.value = filter;

  void dismissNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }

  void markAllAsRead() {
    // In a real app this would call an API
    Get.snackbar('Done', 'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM);
  }
}
