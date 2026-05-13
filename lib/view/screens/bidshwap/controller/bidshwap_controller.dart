import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../model/my_trade_model.dart';
import '../model/trade_model.dart';

class BidShwapController extends GetxController {
  var selectedTopTab = 0.obs;
  final topTabs = ["Browse Trades", "My Trades", "Create Trade"];

  var selectedFilter = 0.obs;
  final filters = ["ALL TRADES", "TRADING CARDS", "SNEAKERS"];

  var selectedMyTradeFilter = 0.obs;
  final myTradeFilters = ["All", "Pending", "Completed"];

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

  final myTrades = <MyTradeModel>[
    MyTradeModel(
      tradeId: "#TR-8821",
      title: "Vintage Leica M6 for Hasselblad 500CM",
      item1Image: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=1000&auto=format&fit=crop",
      item2Image: "https://images.unsplash.com/photo-1495121553079-4c61bbbc19ef?q=80&w=1000&auto=format&fit=crop",
      traderName: "@lensmaster_99",
      status: MyTradeStatus.shipped,
    ),
    MyTradeModel(
      tradeId: "#TR-9044",
      title: "MacBook Pro M2 for iPad Pro & Magic Keyboard",
      item1Image: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1000&auto=format&fit=crop",
      item2Image: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?q=80&w=1000&auto=format&fit=crop",
      traderName: "@tech_enthusiast",
      status: MyTradeStatus.pending,
    ),
    MyTradeModel(
      tradeId: "#TR-8702",
      title: "Jordan 1 Retro High 'Chicago' swap for Travis Scott Lows",
      item1Image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1000&auto=format&fit=crop",
      item2Image: "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=1000&auto=format&fit=crop",
      traderName: "@sneakerhead_nyc",
      traderAvatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1000&auto=format&fit=crop",
      date: "Oct 24, 2023",
      status: MyTradeStatus.completed,
    ),
  ].obs;

  void changeTopTab(int index) {
    selectedTopTab.value = index;
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  void changeMyTradeFilter(int index) {
    selectedMyTradeFilter.value = index;
  }
}
