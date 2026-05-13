import 'package:get/get.dart';
import '../model/my_trade_model.dart';

class MyTradesController extends GetxController {
  var selectedFilter = 0.obs;
  final filters = ["All", "Pending", "Completed"];

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

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
