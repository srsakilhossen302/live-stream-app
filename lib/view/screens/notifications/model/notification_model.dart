enum NotificationType { tradeOffer, liveAlert, outbid, security }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final String? imageUrl;
  final String? avatarUrl;
  final String? currentBid;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.imageUrl,
    this.avatarUrl,
    this.currentBid,
    this.isRead = false,
  });
}

class RecommendedItemModel {
  final String id;
  final String imageUrl;
  final String tag;
  final String title;
  final String description;
  final String actionLabel;

  const RecommendedItemModel({
    required this.id,
    required this.imageUrl,
    required this.tag,
    required this.title,
    required this.description,
    required this.actionLabel,
  });
}
