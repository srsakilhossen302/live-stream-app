import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../model/trade_model.dart';

class BidShwapController extends GetxController {
  var selectedFilter = 0.obs;
  final filters = ["ALL TRADES", "TRADING CARDS", "SNEAKERS"];

  final trades = <TradeModel>[
    TradeModel(
      userName: "Julian_D",
      userAvatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop",
      userRating: "4.9",
      tradesCount: "124 trades",
      offeredItemName: "Charizard 1st Ed PSA 10",
      offeredItemValue: "\$12,500 Est.",
      offeredItemImage: "https://images.unsplash.com/photo-1613771404721-1f92d799e49f?q=80&w=2069&auto=format&fit=crop",
      lookingForItemName: "Rolex Submariner Date",
      lookingForItemValue: "Value Range: \$11k - \$14k",
    ),
  ].obs;

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
