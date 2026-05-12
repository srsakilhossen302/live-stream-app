import 'package:get/get.dart';
import '../model/purchase_model.dart';

class PurchasesController extends GetxController {
  var selectedTab = 0.obs;

  final tabs = ["All", "In Transit", "Delivered", "Cancelled"];

  final purchases = <PurchaseModel>[
    PurchaseModel(
      id: "#ORD-24891",
      title: "Vintage Pokémon Card Pack",
      curator: "@CardMaster",
      date: "Purchased Oct 12, 2023",
      price: "\$1,240.00",
      carrier: "USPS Priority",
      image: "https://i.ebayimg.com/images/g/V~AAAOSw~oFk~S~U/s-l1600.jpg",
      trackingId: "9400 1234 5678 90",
      status: OrderStatus.inTransit,
    ),
    PurchaseModel(
      id: "#ORD-24885",
      title: "Cyber-Runner Lmt. Ed.",
      curator: "@SneakerVault",
      date: "Purchased Oct 08, 2023",
      price: "\$890.00",
      carrier: "FedEx Express",
      image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
      trackingId: "FEDEX-8829-1120",
      status: OrderStatus.delivered,
    ),
    PurchaseModel(
      id: "#ORD-24902",
      title: "Horology Minimalist X",
      curator: "@TimeKeepers",
      date: "Purchased 2 hours ago",
      price: "\$2,450.00",
      carrier: "DHL Express",
      image: "https://images.unsplash.com/photo-1524592094714-0f0654e20314",
      trackingId: "DHL-9901-2234",
      status: OrderStatus.processing,
    ),
  ].obs;

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
