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
      estimatedDelivery: "Apr 23, 2026",
      location: "Jersey City Distribution Center",
      itemPrice: 1150.00,
      shippingPrice: 90.00,
      taxes: 0.00,
      processingFee: 0.00,
      buyerContribution: 0.05,
      totalPaid: 1240.05,
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
      estimatedDelivery: "Delivered Oct 10, 2023",
      location: "New York Hub",
      itemPrice: 850.00,
      shippingPrice: 40.00,
      taxes: 0.00,
      processingFee: 0.00,
      buyerContribution: 0.00,
      totalPaid: 890.00,
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
      estimatedDelivery: "Pending",
      location: "Origin Facility",
      itemPrice: 2400.00,
      shippingPrice: 50.00,
      taxes: 0.00,
      processingFee: 0.00,
      buyerContribution: 0.00,
      totalPaid: 2450.00,
    ),
  ].obs;

  void changeTab(int index) {
    selectedTab.value = index;
  }

  List<PurchaseModel> get filteredPurchases {
    if (selectedTab.value == 0) return purchases;
    
    OrderStatus targetStatus;
    switch (selectedTab.value) {
      case 1:
        targetStatus = OrderStatus.inTransit;
        break;
      case 2:
        targetStatus = OrderStatus.delivered;
        break;
      case 3:
        targetStatus = OrderStatus.cancelled;
        break;
      default:
        return purchases;
    }
    
    return purchases.where((p) => p.status == targetStatus).toList();
  }
}
