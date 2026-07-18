import 'package:get/get.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../model/my_trade_model.dart';

class MyTradesController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final RxBool isLoading = false.obs;

  var selectedFilter = 0.obs;
  final filters = ["All", "Pending", "Completed"];
  final myTrades = <MyTradeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrades();
  }

  Future<void> fetchTrades() async {
    final userId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      final receivedResponse = await _apiClient.getData("${ApiUrl.tradeOffers}?userId=$userId&type=received");
      final sentResponse = await _apiClient.getData("${ApiUrl.tradeOffers}?userId=$userId&type=sent");

      List receivedData = [];
      List sentData = [];

      if (receivedResponse.statusCode == 200) {
        receivedData = jsonDecode(receivedResponse.body)['data'] ?? [];
      }
      if (sentResponse.statusCode == 200) {
        sentData = jsonDecode(sentResponse.body)['data'] ?? [];
      }

      final List allData = [...receivedData, ...sentData];

      final parsed = allData.map((item) {
        final sender = item['senderId'] ?? {};
        final receiver = item['receiverId'] ?? {};
        
        final senderProduct = item['senderProductId'] ?? {};
        final receiverProduct = item['receiverProductId'] ?? {};

        final isUserSender = sender['_id'] == userId;
        final otherUser = isUserSender ? receiver : sender;

        String item1Url = "";
        final senderImages = senderProduct['images'];
        if (senderImages != null && senderImages is List && senderImages.isNotEmpty) {
          final path = senderImages[0].toString();
          item1Url = path.startsWith('http') ? path : "${ApiUrl.imageBaseUrl}${path.startsWith('/') ? path : '/$path'}";
        }

        String item2Url = "";
        final receiverImages = receiverProduct['images'];
        if (receiverImages != null && receiverImages is List && receiverImages.isNotEmpty) {
          final path = receiverImages[0].toString();
          item2Url = path.startsWith('http') ? path : "${ApiUrl.imageBaseUrl}${path.startsWith('/') ? path : '/$path'}";
        }

        final rawStatus = item['status']?.toString().toLowerCase() ?? "pending";
        MyTradeStatus status = MyTradeStatus.pending;
        if (rawStatus.contains('completed')) {
          status = MyTradeStatus.completed;
        } else if (rawStatus.contains('accept') || rawStatus.contains('ship')) {
          status = MyTradeStatus.shipped;
        } else if (rawStatus.contains('pending')) {
          status = MyTradeStatus.pending;
        } else if (rawStatus.contains('decline') || rawStatus.contains('cancel')) {
          status = MyTradeStatus.completed;
        }

        final title = "${senderProduct['title'] ?? 'Item'} for ${receiverProduct['title'] ?? 'Item'}";

        String avatarUrl = "";
        final profilePath = otherUser['profile'] ?? "";
        if (profilePath.isNotEmpty) {
          avatarUrl = profilePath.startsWith('http') ? profilePath : "${ApiUrl.imageBaseUrl}${profilePath.startsWith('/') ? profilePath : '/$profilePath'}";
        }

        return MyTradeModel(
          tradeId: "#TR-${item['_id']?.toString().substring((item['_id']?.toString().length ?? 5) - 5).toUpperCase() ?? ''}",
          title: title,
          item1Image: item1Url,
          item2Image: item2Url,
          traderName: "@${otherUser['username'] ?? 'user'}",
          traderAvatar: avatarUrl.isNotEmpty ? avatarUrl : null,
          date: item['createdAt'] != null ? _formatDate(item['createdAt'].toString()) : "Recently",
          status: status,
          rawObjectId: item['_id']?.toString(),
          isUserSender: isUserSender,
        );
      }).toList();

      myTrades.assignAll(parsed);
    } catch (e) {
      Get.log("Error fetching trade offers: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (_) {
      return "Recently";
    }
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  List<MyTradeModel> get filteredTrades {
    if (selectedFilter.value == 0) return myTrades;
    if (selectedFilter.value == 1) {
      return myTrades.where((t) => t.status == MyTradeStatus.pending || t.status == MyTradeStatus.shipped).toList();
    }
    if (selectedFilter.value == 2) {
      return myTrades.where((t) => t.status == MyTradeStatus.completed).toList();
    }
    return myTrades;
  }

  Future<void> acceptTradeOffer(String rawId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.postData("${ApiUrl.acceptTrade}/$rawId", {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Trade offer accepted successfully!", snackPosition: SnackPosition.BOTTOM);
        await fetchTrades();
      } else {
        Get.snackbar("Error", "Failed to accept trade offer: Status code ${response.statusCode}", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> declineTradeOffer(String rawId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.postData("${ApiUrl.declineTrade}/$rawId", {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Trade offer declined successfully!", snackPosition: SnackPosition.BOTTOM);
        await fetchTrades();
      } else {
        Get.snackbar("Error", "Failed to decline trade offer: Status code ${response.statusCode}", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeTradeOffer(String rawId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.postData("/trades/complete/$rawId", {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final success = body['success'] ?? false;
        final data = body['data'];
        
        if (success) {
          if (data is Map && data.containsKey('checkoutUrl')) {
            final checkoutUrl = data['checkoutUrl'].toString();
            final uri = Uri.parse(checkoutUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              Get.snackbar("Success", "Redirecting to Stripe checkout...", snackPosition: SnackPosition.BOTTOM);
            } else {
              Get.snackbar("Error", "Could not launch Stripe payment.", snackPosition: SnackPosition.BOTTOM);
            }
          } else {
            Get.snackbar("Success", "Trade completed successfully!", snackPosition: SnackPosition.BOTTOM);
          }
          await fetchTrades();
        } else {
          Get.snackbar("Error", body['message'] ?? "Failed to complete trade", snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar("Error", "Failed to complete trade offer. Status: ${response.statusCode}", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
