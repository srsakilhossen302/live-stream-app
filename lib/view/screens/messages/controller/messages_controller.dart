import 'dart:convert';
import 'package:get/get.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../../../../data/helpers/shared_prefe.dart';

class MessagesController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  var selectedFilter = 0.obs;
  var isLoading = true.obs;
  final filters = ["All", "Unread", "Orders", "Trades"];

  final chatRooms = <Map<String, dynamic>>[].obs;
  final updateLogs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchChatRooms();
    fetchNotifications();
  }

  Future<void> fetchChatRooms() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.getData(ApiUrl.chat);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final rawData = decoded['data'];
        
        List chatsList = [];
        if (rawData is List) {
          chatsList = rawData;
        } else if (rawData is Map && rawData['chats'] is List) {
          chatsList = rawData['chats'];
        }

        if (chatsList.isNotEmpty) {
          final List<Map<String, dynamic>> parsedRooms = [];
          for (var room in chatsList) {
            final participants = room['participants'] as List? ?? [];
            final currentUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
            final otherParticipant = participants.firstWhere(
              (p) => p['_id'] != currentUserId,
              orElse: () => participants.isNotEmpty ? participants.first : null,
            );

            if (otherParticipant == null) continue;

            final name = otherParticipant['fullName'] ?? otherParticipant['name'] ?? "User";
            final lastMsg = room['lastMessage'] != null 
                ? (room['lastMessage']['text'] ?? "Sent a message") 
                : "No messages yet";
            final time = room['updatedAt'] ?? "";
            final avatar = otherParticipant['image'] ?? "";
            
            String imageUrl = "";
            if (avatar.isNotEmpty) {
              imageUrl = avatar.startsWith('http')
                  ? avatar
                  : "${ApiUrl.imageBaseUrl}${avatar.startsWith('/') ? avatar : '/$avatar'}";
            } else {
              imageUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200";
            }

            parsedRooms.add({
              "id": room['_id'],
              "name": name.startsWith('@') ? name : "@$name",
              "message": lastMsg,
              "time": _formatTime(time),
              "avatar": imageUrl,
            });
          }
          chatRooms.assignAll(parsedRooms);
        } else {
          // Genuinely empty chat rooms from server database
          chatRooms.clear();
        }
      } else {
        _loadMockChatRooms();
      }
    } catch (e) {
      Get.log("Error fetching chat rooms: $e");
      _loadMockChatRooms();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockChatRooms() {
    chatRooms.assignAll([
      {
        "id": "mock_room_1",
        "name": "@Retro_Rick",
        "message": "can do \$450 if we close tonight. Let me know.",
        "time": "Oct 24",
        "avatar": "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1974&auto=format&fit=crop",
      },
      {
        "id": "mock_room_2",
        "name": "@AuctionQueen",
        "message": "Congratulations! You won the Crimson Blade auction.",
        "time": "Oct 20",
        "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop",
        "isSpecial": true,
      },
      {
        "id": "mock_room_3",
        "name": "@Silent_Bidder",
        "message": "Thanks for the smooth transaction. Left 5 stars.",
        "time": "Oct 15",
        "avatar": "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1974&auto=format&fit=crop",
      },
    ]);

    updateLogs.assignAll([
      {
        "name": "@CardMaster",
        "message": "Your order has been shipped",
        "time": "14:22",
        "hasNew": true,
        "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop",
        "tags": ["#ORD-24891", "Shipped 🚚"],
      },
      {
        "name": "@LuxeVault",
        "message": "Trade request accepted",
        "time": "Yesterday",
        "avatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop",
        "tags": ["TRADE", "Completed 🤝"],
      },
    ]);
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return "Now";
    try {
      final parsed = DateTime.parse(timeStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(parsed);
      if (diff.inDays == 0) {
        return "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      } else if (diff.inDays == 1) {
        return "Yesterday";
      } else {
        return "${parsed.day} ${_getMonthName(parsed.month)}";
      }
    } catch (_) {
      return "Now";
    }
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await _apiClient.getData(ApiUrl.myNotifications);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          final List<Map<String, dynamic>> parsedUpdates = [];
          for (var item in data) {
            final title = item['title'] ?? "Notification";
            final msg = item['message'] ?? "";
            final time = item['createdAt'] ?? "";
            final isRead = item['isRead'] == true;

            parsedUpdates.add({
              "name": title.startsWith('@') ? title : "@$title",
              "message": msg,
              "time": _formatTime(time),
              "hasNew": !isRead,
              "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200",
              "tags": [item['type'] ?? "Alert"],
            });
          }
          updateLogs.assignAll(parsedUpdates);
        } else {
          updateLogs.clear();
        }
      }
    } catch (e) {
      Get.log("Error loading notifications in MessagesController: $e");
    }
  }

  Future<String?> createChatRoom(String targetUserId) async {
    try {
      final response = await _apiClient.postData("${ApiUrl.chat}/$targetUserId", {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return body['data']?['_id'] ?? body['data']?['id'];
      }
    } catch (e) {
      Get.log("Error creating chat room: $e");
    }
    return null;
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
